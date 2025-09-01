import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:simple_todo/core/common/widgets/custom_toast.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/data/local/collection/task_database.dart';
import 'package:simple_todo/core/utils/logger_utils.dart';

import '../../../core/config/app_strings.dart';
import '../../../core/design/app_colors.dart';

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
    if (taskDescription.text.isEmpty) {
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
    final Task task = Task(title: taskTitle.text, description: taskDescription.text);
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

    final List<Task> tasksList = await TaskDatabase().fetchTasks();
    LoggerUtils.debug(tasksList[0].description);
  }

  /// ================ CHANGE TASK STATUS  ==================>
  Future<void> changeStatus({required Task task, required TaskStatus newStatus}) async {
    LoggerUtils.debug(task);
    final Task updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      createdAt: DateTime.now(),
      status: newStatus,
    );
    await TaskDatabase().updateTaskObject(updatedTask);
    await loadTasks();
  }

  /// ================ DELETE TASK ==================>
  Future<void> deleteTask({required int taskId}) async {
    LoggerUtils.debug(taskId);
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

  /// [dispose] Lifecycle method called when the controller is destroyed.
  ///
  /// Cleans up by resetting loading states and clearing lists and more...
  @override
  void dispose() {
    taskTitle.dispose();
    taskDescription.dispose();
    super.dispose();
  }
}
