import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
import '../widgets/quote_card.dart';
import '../widgets/task_card.dart';
import '../widgets/loading_widget.dart';
import 'add_edit_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _quote;
  bool _isLoadingQuote = true;
  String? _quoteError;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  Future<void> _fetchQuote() async {
    setState(() {
      _isLoadingQuote = true;
      _quoteError = null;
    });
    try {
      final quote = await _apiService.fetchQuote();
      setState(() {
        _quote = quote;
        _isLoadingQuote = false;
      });
    } catch (e) {
      setState(() {
        _quoteError = 'Could not load quote';
        _isLoadingQuote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const LoadingWidget()
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Hello, ${user.email?.split('@')[0] ?? 'User'}',
                      style: TextStyle(
                        fontSize: isLandscape ? 20 : 24, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: isLandscape ? 8 : 16),
                    if (_isLoadingQuote)
                      const Center(child: CircularProgressIndicator())
                    else if (_quoteError != null)
                      Center(
                        child: TextButton(
                          onPressed: _fetchQuote,
                          child: const Text('Retry loading quote'),
                        ),
                      )
                    else if (_quote != null)
                      SizedBox(
                        height: isLandscape ? 100 : null,
                        child: SingleChildScrollView(
                          child: QuoteCard(
                            quote: _quote!['content'],
                            author: _quote!['author'],
                            onRefresh: _fetchQuote,
                          ),
                        ),
                      ),
                    SizedBox(height: isLandscape ? 12 : 24),
                    Text(
                      'Your Tasks',
                      style: TextStyle(
                        fontSize: isLandscape ? 18 : 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.indigo
                      ),
                    ),
                    SizedBox(height: isLandscape ? 8 : 12),
                    Expanded(
                      child: StreamBuilder<List<TaskModel>>(
                        stream: _firestoreService.getTasks(user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          final tasks = snapshot.data ?? [];
                          if (tasks.isEmpty) {
                            return Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.task_alt, size: isLandscape ? 50 : 80, color: Colors.indigo.withOpacity(0.2)),
                                    const SizedBox(height: 16),
                                    const Text('No tasks yet. Add one!'),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return TaskCard(
                                task: task,
                                onToggle: (val) {
                                  _firestoreService.toggleTaskStatus(task.id, val ?? false);
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddEditTaskScreen(task: task),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  _firestoreService.deleteTask(task.id);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
