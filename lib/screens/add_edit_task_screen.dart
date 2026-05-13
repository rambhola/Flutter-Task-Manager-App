import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  bool _isCompleted = false;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.date;
      _isCompleted = widget.task!.isCompleted;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.indigo,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final userId = Provider.of<AuthService>(context, listen: false).user!.uid;

      final task = TaskModel(
        id: widget.task?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        isCompleted: _isCompleted,
        userId: userId,
      );

      try {
        if (widget.task == null) {
          await _firestoreService.addTask(task);
        } else {
          await _firestoreService.updateTask(task);
        }
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLandscape)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _titleController,
                          label: 'Task Title',
                          prefixIcon: Icons.title,
                          validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _descriptionController,
                          label: 'Description',
                          prefixIcon: Icons.description_outlined,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      CustomTextField(
                        controller: _titleController,
                        label: 'Task Title',
                        prefixIcon: Icons.title,
                        validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                      ),
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        prefixIcon: Icons.description_outlined,
                      ),
                    ],
                  ),
                const SizedBox(height: 24),
                const Text('Due Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.indigo),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text('Completed Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Switch(
                      value: _isCompleted,
                      onChanged: (val) => setState(() => _isCompleted = val),
                      activeColor: Colors.indigo,
                    ),
                  ],
                ),
                SizedBox(height: isLandscape ? 20 : 40),
                PrimaryButton(
                  text: isEditing ? 'Update Task' : 'Save Task',
                  isLoading: _isLoading,
                  onPressed: _saveTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
