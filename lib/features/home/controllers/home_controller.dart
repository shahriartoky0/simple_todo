import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:simple_todo/core/common/widgets/custom_toast.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/data/local/collection/task_database.dart';
import 'package:simple_todo/core/utils/logger_utils.dart';

import '../../../core/config/app_strings.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/utils/file_manager_service.dart';

class HomeController extends GetxController {
  final TextEditingController taskTitle = TextEditingController();
  final TextEditingController taskDescription = TextEditingController();

  /// For storing the task list ===========>
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

  /// ================ ADD TASK ==================>
  Future<void> addTask() async {
    // FIX: Validate both title and description before adding.
    // if (taskTitle.text.trim().isEmpty) {
    //   ToastManager.show(
    //     message: AppStrings.giveATitle.tr,
    //     icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
    //     textColor: AppColors.white,
    //     backgroundColor: AppColors.darkRed,
    //     animationDuration: const Duration(milliseconds: 900),
    //     animationCurve: Curves.easeInSine,
    //     fromTop: true,
    //     duration: const Duration(seconds: 1),
    //   );
    //   return;
    // }

    if (taskDescription.text.trim().isEmpty) {
      ToastManager.show(
        message: AppStrings.giveADescription.tr,
        icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
        textColor: AppColors.white,
        backgroundColor: AppColors.darkRed,
        animationDuration: const Duration(milliseconds: 900),
        animationCurve: Curves.easeInSine,
        fromTop: true,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    final Task task = Task(title: taskTitle.text.trim(), description: taskDescription.text.trim());
    await TaskDatabase().addTask(task);
    Get.back();

    /// Show the toast ===>
    ToastManager.show(
      message: AppStrings.taskAdded.tr,
      icon: const Icon(CupertinoIcons.doc_plaintext, color: AppColors.white),
      backgroundColor: AppColors.primaryColor,
      animationDuration: const Duration(milliseconds: 900),
      animationCurve: Curves.easeInSine,
      duration: const Duration(seconds: 2),
    );

    /// clear the text-field ===>
    taskTitle.clear();
    taskDescription.clear();

    /// Refresh the list
    await loadTasks();
  }

  /// ================ Update The Existing TASK ==================>
  Future<void> editTask({required Task existingTask}) async {
    if (taskTitle.text.trim().isEmpty) {
      ToastManager.show(
        message: AppStrings.giveATitle.tr,
        icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
        textColor: AppColors.white,
        backgroundColor: AppColors.darkRed,
        animationDuration: const Duration(milliseconds: 900),
        animationCurve: Curves.easeInSine,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    if (taskDescription.text.trim().isEmpty) {
      ToastManager.show(
        message: AppStrings.giveADescription.tr,
        icon: const Icon(CupertinoIcons.info_circle_fill, color: AppColors.white),
        textColor: AppColors.white,
        backgroundColor: AppColors.darkRed,
        animationDuration: const Duration(milliseconds: 900),
        animationCurve: Curves.easeInSine,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    await TaskDatabase().updateTask(
      existingTask.id,
      newDescription: taskDescription.text.trim(),
      newTitle: taskTitle.text.trim(),
    );
    Get.back();

    /// Show the toast ===>
    ToastManager.show(
      message: AppStrings.taskUpdated.tr,
      icon: const Icon(CupertinoIcons.doc_checkmark, color: AppColors.white),
      backgroundColor: AppColors.primaryColor,
      animationDuration: const Duration(milliseconds: 900),
      animationCurve: Curves.easeInSine,
      duration: const Duration(seconds: 2),
    );

    /// clear the text-field ===>
    taskTitle.clear();
    taskDescription.clear();

    /// Refresh the list
    await loadTasks();
  }

  /// ================ CHANGE TASK STATUS  ==================>
  Future<void> changeStatus({required Task task, required TaskStatus newStatus}) async {
    LoggerUtils.debug(task);
    final Task updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: task.createdAt, // FIX: preserve the original createdAt instead of DateTime.now()
      status: newStatus,
    );
    await TaskDatabase().updateTaskObject(updatedTask);
    await loadTasks();
  }

  /// ================ DELETE TASK ==================>
  Future<void> deleteTask({required int taskId}) async {
    LoggerUtils.debug(taskId);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await TaskDatabase().deleteTask(taskId);

    /// Show the toast ===>
    ToastManager.show(
      message: AppStrings.taskRemoved.tr,
      icon: const Icon(CupertinoIcons.check_mark_circled, color: AppColors.white),
      textColor: AppColors.white,
      backgroundColor: AppColors.darkRed,
      animationDuration: const Duration(milliseconds: 900),
      animationCurve: Curves.easeInSine,
      duration: const Duration(seconds: 2),
    );
    await loadTasks();
  }

  /// =========================================== Export - Import  File =================================>
  Future<void> exportTasksToCSV() async {
    try {
      // FIX: Always fetch the latest tasks fresh from the database right before
      // exporting, then snapshot them with .toList() so the static service method
      // receives a plain, immutable List<Task> — not a live RxList whose reactive
      // wrapper can yield an empty iteration once the call crosses an async boundary.
      await loadTasks();
      final List<Task> snapshot = taskList.toList();

      if (snapshot.isEmpty) {
        ToastManager.show(
          message: AppStrings.noTasksToImport.tr,
          icon: const Icon(CupertinoIcons.info_circle, color: AppColors.white),
          backgroundColor: AppColors.darkRed,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final bool success = await FileManagerService.exportTasksToCSV(snapshot);
      if (!success) {
        ToastManager.show(
          message: AppStrings.exportFailed.tr,
          icon: const Icon(CupertinoIcons.xmark_circle, color: AppColors.white),
          backgroundColor: AppColors.darkRed,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      ToastManager.show(
        message: '${AppStrings.exportFailed.tr} $e',
        icon: const Icon(CupertinoIcons.xmark_circle, color: AppColors.white),
        backgroundColor: AppColors.darkRed,
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Import tasks from CSV or JSON
  Future<void> importTasks() async {
    try {
      Get.back();
      final List<Task>? importedTasks = await FileManagerService.importTasks();

      if (importedTasks != null && importedTasks.isNotEmpty) {
        // Add tasks to database
        for (final Task task in importedTasks) {
          await TaskDatabase().addTask(task);
        }

        // Refresh task list
        await loadTasks();

        ToastManager.show(
          message: '${importedTasks.length} ${AppStrings.taskImportSuccess.tr}',
          icon: const Icon(CupertinoIcons.checkmark_circle, color: AppColors.white),
          backgroundColor: AppColors.primaryColor,
          duration: const Duration(seconds: 2),
        );
      } else {
        ToastManager.show(
          message: AppStrings.noTasksToImport.tr,
          icon: const Icon(CupertinoIcons.info_circle, color: AppColors.white),
          backgroundColor: AppColors.darkRed,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      ToastManager.show(
        message: 'Import failed: $e',
        icon: const Icon(CupertinoIcons.xmark_circle, color: AppColors.white),
        backgroundColor: AppColors.darkRed,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// [onClose] Lifecycle method called when the controller is destroyed.
  ///
  /// FIX: Removed the duplicate dispose() override. In GetX, onClose() is the
  /// correct place to clean up resources. Having both onClose() and dispose()
  /// caused the TextEditingControllers to be disposed twice, which can lead to
  /// "A TextEditingController was used after being disposed" errors.
  @override
  void onClose() {
    taskTitle.dispose();
    taskDescription.dispose();
    super.onClose();
  }
}