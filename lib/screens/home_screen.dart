import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/task_controller.dart';
import '../widgets/quote_card.dart';
import '../widgets/task_card.dart';
import '../widgets/loading_widget.dart';
import 'add_edit_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends GetView<TaskController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.user;
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
              await authController.logout();
              Get.offAll(() => const LoginScreen());
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
                    Obx(() {
                      if (controller.isLoadingQuote.value) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (controller.quoteError.value != null) {
                        return Center(
                          child: TextButton(
                            onPressed: controller.fetchQuote,
                            child: const Text('Retry loading quote'),
                          ),
                        );
                      } else if (controller.quote.value != null) {
                        return SizedBox(
                          height: isLandscape ? 100 : null,
                          child: SingleChildScrollView(
                            child: QuoteCard(
                              quote: controller.quote.value!['content'],
                              author: controller.quote.value!['author'],
                              onRefresh: controller.fetchQuote,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
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
                      child: Obx(() {
                        final tasks = controller.tasks;
                        if (tasks.isEmpty) {
                          return Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.task_alt, size: isLandscape ? 50 : 80, color: Colors.indigo.withValues(alpha: 0.2)),
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
                                controller.toggleTaskStatus(task, val);
                              },
                              onTap: () {
                                Get.to(() => AddEditTaskScreen(task: task));
                              },
                              onDelete: () {
                                controller.deleteTask(task.id);
                              },
                            );
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
