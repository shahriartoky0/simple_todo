// simple_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_todo/core/extensions/context_extensions.dart';

import '../../design/app_colors.dart';

/// Super simple bottom sheet without theme dependency
class CustomBottomSheet extends StatelessWidget {
  const CustomBottomSheet({super.key, required this.child, this.title, this.height});

  final Widget child;
  final String? title;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final double calculatedHeight =
        height ??
        (child is Scrollable || child is SingleChildScrollView
            ? MediaQuery.of(context).size.height * 0.4
            : null) ??
        250.0;

    return Container(
      height: calculatedHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(width: 5.0, color: AppColors.primaryColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(title!, style: context.txtTheme.labelLarge),
            ),

          // Content
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)),
        ],
      ),
    );
  }

  /// Show basic bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double? height,
    bool isDismissible = true,
    bool isScrollControlled = true,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      sheetAnimationStyle: const AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 300),
        reverseCurve: Curves.easeOutSine,
        reverseDuration: Duration(milliseconds: 300),
      ),
      builder:
          (BuildContext context) => CustomBottomSheet(title: title, height: height, child: child),
    );
  }
}
