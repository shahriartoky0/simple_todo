import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/task_controller.dart';

class TaskScreen extends GetView<TaskController> {
  const TaskScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        centerTitle: true,
      ),
      body: Center(
        child: Obx(() => Text('Count: ${controller.count}')),
      ),
    );
  }
}
