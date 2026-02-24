import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:simple_todo/core/common/widgets/custom_toast.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/data/local/collection/task_database.dart';
import 'package:simple_todo/core/utils/logger_utils.dart';

import '../../../core/config/app_strings.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/utils/file_manager_service.dart';

enum ExportFormat { csv, pdf }

class HomeController extends GetxController {
  final TextEditingController taskTitle = TextEditingController();
  final TextEditingController taskDescription = TextEditingController();

  final RxList<Task> taskList = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final List<Task> tasks = await TaskDatabase().fetchTasks();
    taskList.assignAll(tasks);
  }

  // ─── Add ───────────────────────────────────────────────────────────────────

  Future<void> addTask() async {
    if (taskTitle.text.trim().isEmpty) {
      _showErrorToast(AppStrings.giveATitle.tr);
      return;
    }
   else if (taskDescription.text
        .trim()
        .isEmpty) {
      _showErrorToast(AppStrings.giveADescription.tr);
      return;
    }
    final Task task = Task(
      title: taskTitle.text.trim(),
      description: taskDescription.text.trim(),
    );
    await TaskDatabase().addTask(task);
    Get.back();
    _showSuccessToast(AppStrings.taskAdded.tr, CupertinoIcons.doc_plaintext);
    taskTitle.clear();
    taskDescription.clear();
    await loadTasks();
  }

  // ─── Edit ──────────────────────────────────────────────────────────────────

  Future<void> editTask({required Task existingTask}) async {
    if (taskTitle.text.trim().isEmpty) {
      _showErrorToast(AppStrings.giveATitle.tr);
      return;
    }
    if (taskDescription.text.trim().isEmpty) {
      _showErrorToast(AppStrings.giveADescription.tr);
      return;
    }
    await TaskDatabase().updateTask(
      existingTask.id,
      newTitle: taskTitle.text.trim(),
      newDescription: taskDescription.text.trim(),
    );
    Get.back();
    _showSuccessToast(AppStrings.taskUpdated.tr, CupertinoIcons.doc_checkmark);
    taskTitle.clear();
    taskDescription.clear();
    await loadTasks();
  }

  // ─── Status ────────────────────────────────────────────────────────────────

  Future<void> changeStatus({
    required Task task,
    required TaskStatus newStatus,
  }) async {
    LoggerUtils.debug(task);
    await TaskDatabase().updateTaskObject(
      Task(
        id: task.id,
        title: task.title,
        description: task.description,
        createdAt: task.createdAt,
        status: newStatus,
      ),
    );
    await loadTasks();
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> deleteTask({required int taskId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await TaskDatabase().deleteTask(taskId);
    ToastManager.show(
      message: AppStrings.taskRemoved.tr,
      icon: const Icon(
        CupertinoIcons.check_mark_circled,
        color: AppColors.white,
      ),
      textColor: AppColors.white,
      backgroundColor: AppColors.darkRed,
      animationDuration: const Duration(milliseconds: 900),
      animationCurve: Curves.easeInSine,
      duration: const Duration(seconds: 2),
    );
    await loadTasks();
  }

  // ─── Export ────────────────────────────────────────────────────────────────

  /// Builds the file and opens the OS share sheet.
  /// No success toast — the share sheet IS the user-facing confirmation.
  /// An error toast is shown only if the export itself fails before the share
  /// sheet can open (e.g. disk write error).
  Future<void> exportAs(ExportFormat format) async {
    final List<Task>? snapshot = await _getExportSnapshot();
    if (snapshot == null) return;

    final bool ok = format == ExportFormat.csv
        ? await FileManagerService.exportTasksToCSV(snapshot)
        : await FileManagerService.exportTasksToPDF(snapshot);

    // Only show a toast on failure. On success the OS share sheet is the UI.
    if (!ok) {
      _showErrorToast(AppStrings.exportFailed.tr);
    }
  }

  // ─── Import ────────────────────────────────────────────────────────────────

  Future<void> importTasks() async {
    try {
      Get.back(); // close the bottom sheet before opening file picker

      final List<Task>? imported = await FileManagerService.importTasks();

      // null = user cancelled the file picker — do nothing silently
      if (imported == null) return;

      for (final Task task in imported) {
        await TaskDatabase().addTask(task);
      }
      await loadTasks();
      _showSuccessToast(
        '${imported.length} ${AppStrings.taskImportSuccess.tr}',
        CupertinoIcons.checkmark_circle,
      );
    } catch (e) {
      // _ImportException carries a user-readable message; any other exception
      // falls back to a generic message. Both are shown as error toasts.
      _showErrorToast(e.toString());
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<List<Task>?> _getExportSnapshot() async {
    try {
      await loadTasks();
      final List<Task> snapshot = taskList.toList();
      if (snapshot.isEmpty) {
        _showErrorToast(AppStrings.noTasksToImport.tr);
        return null;
      }
      return snapshot;
    } catch (e) {
      _showErrorToast('${AppStrings.exportFailed.tr}: $e');
      return null;
    }
  }

  void _showSuccessToast(String message, IconData iconData) {
    ToastManager.show(
      message: message,
      icon: Icon(iconData, color: AppColors.white),
      backgroundColor: AppColors.primaryColor,
      animationDuration: const Duration(milliseconds: 900),
      animationCurve: Curves.easeInSine,
      duration: const Duration(seconds: 2),
    );
  }

  void _showErrorToast(String message) {
    ToastManager.show(
      message: message,
      icon: const Icon(
        CupertinoIcons.info_circle_fill,
        color: AppColors.white,
      ),
      textColor: AppColors.white,
      backgroundColor: AppColors.darkRed,
      animationDuration: const Duration(milliseconds: 900),
      animationCurve: Curves.easeInSine,
      fromTop: true,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    taskTitle.dispose();
    taskDescription.dispose();
    super.onClose();
  }
}