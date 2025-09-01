import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_todo/core/common/widgets/custom_appbar.dart';
import 'package:simple_todo/core/common/widgets/custom_modal.dart';
import 'package:simple_todo/core/config/app_strings.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/extensions/context_extensions.dart';
import 'package:simple_todo/core/utils/logger_utils.dart';
import '../../../core/config/app_sizes.dart';
import '../controllers/home_controller.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.headlineText,
      appBar: CustomAppBar(label: AppStrings.myToDoList.tr, hasLeading: false),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ///======> To-DO list ======>
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHorizontal),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return TaskTile(
                  taskStatus: TaskStatus.ready,
                  taskTitle: 'Task Title',
                  taskDescription: 'Task is to make the app',
                  taskTime: 'By 2 days ....',
                  onEdit: () {},
                  onDelete: () {},
                  onStatusChanged: (TaskStatus taskStatus) {
                    LoggerUtils.debug(taskStatus.name);
                  },
                );
              },
              separatorBuilder: (_, _) {
                return const SizedBox(height: AppSizes.md);
              },
              itemCount: 10,
            ),
          ],
        ),
      ),

      /// ==============> Add Task Button ===================>
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Get.toNamed(AppRoutes.taskRoute);
          // CustomBottomSheet.show(context: context, child: const Text('data'));
          CustomBottomSheet.show(
            context: context,
            title: AppStrings.addNewTask.tr,
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: <Widget>[
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
                  child: ElevatedButton(onPressed: () {

                  }, child: Text(AppStrings.addTask.tr)),
                ),
              ],
            ),
          );
        },
        label: Text(AppStrings.addTask.tr),
        icon: const Icon(CupertinoIcons.doc_plaintext),
      ),
    );
  }
}
