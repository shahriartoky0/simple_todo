import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_todo/core/common/widgets/custom_appbar.dart';
import 'package:simple_todo/core/common/widgets/custom_modal.dart';
import 'package:simple_todo/core/config/app_asset_path.dart';
import 'package:simple_todo/core/config/app_strings.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/design/app_colors.dart';
import 'package:simple_todo/core/extensions/context_extensions.dart';
import 'package:simple_todo/core/extensions/date_time_extensions.dart';
import 'package:simple_todo/core/extensions/widget_extensions.dart';
import 'package:simple_todo/features/home/widgets/tile_animation.dart';
import '../../../core/config/app_sizes.dart';
import '../controllers/home_controller.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        label: AppStrings.myToDoList.tr,
        actions: <Widget>[
          Obx(
                () => Visibility(
              visible: controller.taskList.isNotEmpty,
              child: TextButton(
                onPressed: () => _showExportSheet(context),
                child: Text(
                  AppStrings.export.tr,
                  style: context.txtTheme.titleSmall,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Obx(
                  () => controller.taskList.isEmpty
                  ? Column(
                children: <Widget>[
                  SizedBox(height: context.screenHeight * 0.15),
                  Lottie.asset(
                    animate: true,
                    repeat: true,
                    AppAssetPath.emptyTodoAnimation,
                  ).centered,
                ],
              )
                  : ListView.separated(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenHorizontal,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.taskList.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppSizes.md),
                itemBuilder: (BuildContext context, int index) {
                  final Task task = controller.taskList[index];
                  return AnimatedTaskTile(
                    index: index,
                    child: Dismissible(
                      key: Key('task_${task.id}'),
                      onDismissed: (_) =>
                          controller.deleteTask(taskId: task.id),
                      background: const Icon(
                        CupertinoIcons.delete_solid,
                        color: AppColors.darkRed,
                        size: 36,
                      ),
                      child: TaskTile(
                        taskStatus: task.status,
                        taskTitle: task.title,
                        taskDescription: task.description,
                        taskTime: task.createdAt?.smartDate ??
                            AppStrings.aWhileAgo.tr,
                        onEdit: () {
                          controller.taskTitle.text = task.title;
                          controller.taskDescription.text =
                              task.description;
                          _taskModal(
                            forEdit: true,
                            context: context,
                            onPressed: () =>
                                controller.editTask(existingTask: task),
                          );
                        },
                        onDelete: () =>
                            controller.deleteTask(taskId: task.id),
                        onStatusChanged: (TaskStatus status) =>
                            controller.changeStatus(
                              task: task,
                              newStatus: status,
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _taskModal(
          context: context,
          onPressed: controller.addTask,
        ),
        label: Text(AppStrings.addTask.tr),
        icon: const Icon(CupertinoIcons.doc_plaintext),
      ),
    );
  }

  // ─── Export sheet: just two clean options ──────────────────────────────────

  Future<void> _showExportSheet(BuildContext context) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Export Tasks'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              controller.exportAs(ExportFormat.csv);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(CupertinoIcons.doc_text, size: 20),
                SizedBox(width: 10),
                Text('Export as CSV'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              controller.exportAs(ExportFormat.pdf);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(CupertinoIcons.doc_richtext, size: 20),
                SizedBox(width: 10),
                Text('Export as PDF'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // ─── Add / Edit task modal ─────────────────────────────────────────────────

  Future<dynamic> _taskModal({
    required BuildContext context,
    required VoidCallback onPressed,
    bool forEdit = false,
  }) {
    // Create the FocusNode here so it lives for the modal's lifetime.
    final FocusNode descriptionFocus = FocusNode();

    return CustomBottomSheet.show(
      context: context,
      title: forEdit ? AppStrings.editTheTask.tr : AppStrings.addNewTask.tr,
      height: MediaQuery.of(context).size.height * 0.75,
      // FIX: Request focus AFTER the sheet's open animation completes.
      // 100 ms was too short on most devices — the sheet wasn't in the tree yet.
      // 350 ms covers the standard bottom-sheet animation (300 ms) with a small buffer.
      onOpened: () => Future<void>.delayed(
        const Duration(milliseconds: 350),
            () {
          if (descriptionFocus.canRequestFocus) {
            descriptionFocus.requestFocus();
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!forEdit)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.importTasks,
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
            textInputAction: TextInputAction.next,
            // Pressing "Next" on the title keyboard moves focus to description.
            onFieldSubmitted: (_) => descriptionFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: AppStrings.taskTitle.tr,
              hintText: AppStrings.enterTheTaskTitle.tr,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          TextFormField(
            controller: controller.taskDescription,
            focusNode: descriptionFocus,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onPressed(),
            decoration: InputDecoration(
              labelText: AppStrings.taskDescription.tr,
            ),
            minLines: 6,
            maxLines: 8,
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: context.screenWidth * 0.9,
            child: ElevatedButton(
              onPressed: onPressed,
              child: Text(
                forEdit ? AppStrings.updateTask.tr : AppStrings.addTask.tr,
              ),
            ),
          ),
        ],
      ),
    );
  }
}