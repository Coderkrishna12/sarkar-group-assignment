import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

/// Service class for all Firestore CRUD operations on tasks.
/// Tasks are stored under users/{userId}/tasks/{taskId}.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns a reference to the tasks subcollection for a given user.
  CollectionReference _tasksCollection(String userId) {
    return _db.collection('users').doc(userId).collection('tasks');
  }

  /// Adds a new task to Firestore.
  /// Returns the document reference of the newly created task.
  Future<DocumentReference> addTask(TaskModel task) async {
    try {
      return await _tasksCollection(task.userId).add(task.toMap());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  /// Updates an existing task in Firestore.
  Future<void> updateTask(TaskModel task) async {
    try {
      await _tasksCollection(task.userId).doc(task.id).update(task.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }

  /// Deletes a task from Firestore by its ID.
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _tasksCollection(userId).doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Toggles the completion status of a task.
  Future<void> toggleComplete(String userId, String taskId, bool current) async {
    try {
      await _tasksCollection(userId).doc(taskId).update({
        'isCompleted': !current,
      });
    } catch (e) {
      throw Exception('Failed to toggle task status: $e');
    }
  }

  /// Returns a real-time stream of tasks for a specific user,
  /// ordered by date descending (newest first).
  Stream<QuerySnapshot> getTasks(String userId) {
    return _tasksCollection(userId)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
