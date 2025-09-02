import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_todo/core/extensions/context_extensions.dart';
import '../../config/app_sizes.dart';
import '../../design/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final bool hasLeading;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.label, this.hasLeading = false, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading:
          hasLeading
              ? IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(CupertinoIcons.back, size: 20, color: AppColors.primaryColor),
              )
              : null,
      centerTitle: true,
      title: Text(label, style: context.txtTheme.headlineMedium),
      actions:
          actions ??
          <Widget>[
            const SizedBox(width: AppSizes.xxl),
            // You can add additional actions if necessary
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Set the height of the app bar
}
