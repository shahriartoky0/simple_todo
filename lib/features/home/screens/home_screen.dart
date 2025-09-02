import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_todo/core/common/widgets/custom_appbar.dart';
import 'package:simple_todo/core/common/widgets/custom_modal.dart';
import 'package:simple_todo/core/config/app_strings.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/extensions/context_extensions.dart';
import 'package:simple_todo/core/extensions/date_time_extensions.dart';
import 'package:simple_todo/features/home/widgets/tile_animation.dart';
import '../../../core/config/app_sizes.dart';
import '../controllers/home_controller.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.headlineText,
      appBar: CustomAppBar(
        label: AppStrings.myToDoList.tr,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              controller.exportTasksToCSV();
            },
            child: Text(AppStrings.export.tr, style: context.txtTheme.titleSmall),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ///======> To-DO list ======>
            Obx(
              () => ListView.separated(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  final Task task = controller.taskList[index];

                  return AnimatedTaskTile(
                    index: index,
                    child: TaskTile(
                      taskStatus: task.status,
                      taskTitle: task.title,
                      taskDescription: task.description,
                      taskTime: task.createdAt?.smartDate ?? AppStrings.aWhileAgo.tr,
                      onEdit: () {
                        /// ==============For Editing the existing task =============>
                        controller.taskTitle.text = task.title;
                        controller.taskDescription.text = task.description;
                        taskModal(
                          forEdit: true,
                          context: context,
                          onPressed: () {
                            controller.editTask(existingTask: task);
                          },
                        );
                      },
                      onDelete: () {
                        controller.deleteTask(taskId: task.id);
                      },
                      onStatusChanged: (TaskStatus taskStatus) {
                        // LoggerUtils.debug(taskStatus.name);
                        controller.changeStatus(task: task, newStatus: taskStatus);
                      },
                    ),
                  );
                },
                separatorBuilder: (_, __) {
                  return const SizedBox(height: AppSizes.md);
                },
                itemCount: controller.taskList.length,
              ),
            ),
          ],
        ),
      ),

      /// ==============> Add Task Button ===================>
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          taskModal(
            context: context,
            onPressed: () {
              controller.addTask();
            },
          );
        },
        label: Text(AppStrings.addTask.tr),
        icon: const Icon(CupertinoIcons.doc_plaintext),
      ),
    );
  }

  Future<dynamic> taskModal({
    required BuildContext context,
    required VoidCallback onPressed,
    bool forEdit = false,
  }) {
    return CustomBottomSheet.show(
      context: context,
      title: forEdit ? AppStrings.editTheTask.tr : AppStrings.addNewTask.tr,
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (forEdit)
            const SizedBox.shrink()
          else
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  controller.importTasks();
                },
                child: Text(
                  AppStrings.import.tr,
                  style: context.txtTheme.titleSmall?.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSizes.lg),
          TextFormField(
            controller: controller.taskTitle,
            decoration: InputDecoration(
              labelText: AppStrings.taskTitle.tr,
              hintText: AppStrings.enterTheTaskTitle.tr,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          TextFormField(
            controller: controller.taskDescription,
            decoration: InputDecoration(labelText: AppStrings.taskDescription.tr),
            minLines: 6,
            maxLines: 8,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: context.screenWidth * 0.9,
            child: ElevatedButton(
              onPressed: onPressed,
              child: Text(forEdit ? AppStrings.updateTask.tr : AppStrings.addTask.tr),
            ),
          ),
        ],
      ),
    );
  }
}
