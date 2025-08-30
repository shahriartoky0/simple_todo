import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_todo/core/config/app_strings.dart';
import 'package:simple_todo/core/data/local/collection/task.dart';
import 'package:simple_todo/core/design/app_colors.dart';
import 'package:simple_todo/core/extensions/context_extensions.dart';
import 'package:simple_todo/core/extensions/strings_extensions.dart';
import 'package:simple_todo/core/extensions/widget_extensions.dart';
import '../../../core/config/app_sizes.dart';

class TaskTile extends StatelessWidget {
  final TaskStatus taskStatus;
  final String taskTitle;
  final String taskDescription;
  final String taskTime;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.taskStatus,
    required this.taskTitle,
    required this.taskDescription,
    required this.taskTime,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.white.withValues(alpha: 0.9),
            AppColors.white.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXxl),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.2), width: 1.5),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.task_alt_rounded,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(child: Text(taskTitle, style: context.txtTheme.labelLarge)),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: PopupMenuButton<String>(
                        onSelected: (String value) {
                          // Handle menu selection
                          switch (value) {
                            case 'edit':
                              onEdit();
                              break;
                            case 'delete':
                              onDelete();
                              break;
                          }
                        },
                        itemBuilder:
                            (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: <Widget>[
                                    const Icon(Icons.edit, color: AppColors.black, size: 20),
                                    const SizedBox(width: AppSizes.sm),
                                    Text(
                                      AppStrings.editTask.tr,
                                      style: context.txtTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      CupertinoIcons.delete_solid,
                                      color: AppColors.darkRed,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    Text(
                                      AppStrings.deleteTask.tr,
                                      style: context.txtTheme.titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                        icon: const Icon(Icons.more_vert, color: AppColors.grey).centered,
                        offset: Offset.zero, // Positions menu below the button
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                Text(taskDescription),
                const SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(Icons.schedule_rounded, color: AppColors.grey, size: 18),
                        const SizedBox(width: AppSizes.sm),
                        Text(taskTime, style: context.txtTheme.bodySmall),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              taskStatus == TaskStatus.completed
                                  ? <Color>[AppColors.green, AppColors.green.withValues(alpha: 0.8)]
                                  : taskStatus == TaskStatus.ready
                                  ? <Color>[
                                    AppColors.primaryColor,
                                    AppColors.primaryColor.withValues(alpha: 0.8),
                                  ]
                                  : <Color>[
                                    AppColors.orange,
                                    AppColors.orange.withValues(alpha: 0.8),
                                  ],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.borderRadiusXl),
                      ),
                      child: Text(
                        taskStatus.name.toCapitalize,
                        style: context.txtTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
