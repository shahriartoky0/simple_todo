import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import '../database_manager.dart';

class TaskDatabase {
  // Constructor that ensures database is initialized
  TaskDatabase() {
    // Make sure to await initialization before using
    _ensureInitialized();
  }

  // Ensure database is initialized
  Future<void> _ensureInitialized() async {
    await DatabaseManager.initialize();
  }

  // Creating a task
  Future<int> addTask(Task task) async {
    await _ensureInitialized();
    return await DatabaseManager.isar.writeTxn(() => DatabaseManager.isar.tasks.put(task));
  }

  // Fetch specific task
  Future<Task?> getTaskById(int id) async {
    await _ensureInitialized();
    return await DatabaseManager.isar.tasks.get(id);
  }

  // Fetch all tasks
  Future<List<Task>> fetchTasks() async {
    await _ensureInitialized();
    final List<Task> fetchedTasks = await DatabaseManager.isar.tasks.where().findAll();
    return fetchedTasks;
  }

  // Fetch tasks by status
  Future<List<Task>> fetchTasksByStatus(TaskStatus status) async {
    await _ensureInitialized();
    final List<Task> filteredTasks =
    await DatabaseManager.isar.tasks.filter().statusEqualTo(status).findAll();
    return filteredTasks;
  }

  // Update a Task
  Future<void> updateTask(
      int id, {
        String? newTitle,
        String? newDescription,
        TaskStatus? newStatus,
      }) async {
    await _ensureInitialized();
    final Task? existingTask = await DatabaseManager.isar.tasks.get(id);
    if (existingTask != null) {
      if (newTitle != null) {
        existingTask.title = newTitle;
      }
      if (newDescription != null) {
        existingTask.description = newDescription;
      }
      if (newStatus != null) {
        existingTask.status = newStatus;
      }

      await DatabaseManager.isar.writeTxn(() => DatabaseManager.isar.tasks.put(existingTask));
    }
  }

  // Update entire task object
  Future<void> updateTaskObject(Task task) async {
    await _ensureInitialized();
    await DatabaseManager.isar.writeTxn(() => DatabaseManager.isar.tasks.put(task));
  }

  // Delete a Task
  Future<void> deleteTask(int id) async {
    await _ensureInitialized();
    try {
      await DatabaseManager.isar.writeTxn(() => DatabaseManager.isar.tasks.delete(id));
      debugPrint('Task deleted successfully');
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    await _ensureInitialized();
    await DatabaseManager.isar.writeTxn(() => DatabaseManager.isar.tasks.clear());
  }

  // Search tasks by title
  Future<List<Task>> searchTasksByTitle(String query) async {
    await _ensureInitialized();
    final List<Task> searchedTasks =
    await DatabaseManager.isar.tasks
        .filter()
        .titleContains(query, caseSensitive: false)
        .findAll();
    return searchedTasks;
  }

  // Get tasks count
  Future<int> getTasksCount() async {
    await _ensureInitialized();
    return await DatabaseManager.isar.tasks.count();
  }

  // Get tasks count by status
  Future<int> getTasksCountByStatus(TaskStatus status) async {
    await _ensureInitialized();
    return await DatabaseManager.isar.tasks.filter().statusEqualTo(status).count();
  }

  // Mark task as completed
  Future<void> markTaskAsCompleted(int id) async {
    await updateTask(id, newStatus: TaskStatus.completed);
  }

  // Mark task as pending
  Future<void> markTaskAsPending(int id) async {
    await updateTask(id, newStatus: TaskStatus.pending);
  }

  // Mark task as ready
  Future<void> markTaskAsReady(int id) async {
    await updateTask(id, newStatus: TaskStatus.ready);
  }

  // Stream methods for real-time updates
  Stream<List<Task>> watchAllTasks() {
    return DatabaseManager.isar.tasks.where().watch(fireImmediately: true);
  }

  Stream<List<Task>> watchTasksByStatus(TaskStatus status) {
    return DatabaseManager.isar.tasks.filter().statusEqualTo(status).watch(fireImmediately: true);
  }
}