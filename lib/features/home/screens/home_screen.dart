import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_todo/core/common/widgets/custom_appbar.dart';
import 'package:simple_todo/core/config/app_strings.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/utils/logger_utils.dart';
import '../../../core/config/app_sizes.dart';
import '../controllers/home_controller.dart';
import '../widgets/task_tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(label: AppStrings.myToDoList.tr, hasLeading: false),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ///======> To-DO list ======>
            ListView.separated(
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
        onPressed: () {},
        label: Text("Add Task"),
        icon: const Icon(CupertinoIcons.doc_plaintext),
      ),
    );
  }
}
