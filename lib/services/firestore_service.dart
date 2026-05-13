import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  Stream<List<TaskModel>> getTasks(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) =>
            TaskModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTask(TaskModel task) async {
    if (task.userId.isEmpty) {
      throw Exception("User ID cannot be empty when adding a task");
    }
    await _db.collection(_collection).add(task.toMap());
  }

  Future<void> updateTask(TaskModel task) async {
    if (task.id.isEmpty) {
      throw Exception("Task ID cannot be empty when updating a task");
    }

    await _db.collection(_collection).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection(_collection).doc(taskId).delete();
  }

  Future<void> toggleTaskStatus(String taskId, bool isCompleted) async {
    await _db
        .collection(_collection)
        .doc(taskId)
        .update({'isCompleted': isCompleted});
  }
}