import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_todo/core/config/app_sizes.dart';
import 'package:simple_todo/core/extensions/context_extensions.dart';

import '../../design/app_colors.dart';

/// Super simple bottom sheet without theme dependency
class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.height,
    this.onOpened,
  });

  final Widget child;
  final String? title;
  final double? height;

  /// Called once, after the sheet's first frame is rendered.
  /// Use this to request focus on a text field inside the sheet.
  final VoidCallback? onOpened;

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();

  /// Show basic bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    double? height,
    bool isDismissible = true,
    bool isScrollControlled = true,
    VoidCallback? onOpened,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      useSafeArea: true,
      sheetAnimationStyle: const AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 300),
        reverseCurve: Curves.easeOutSine,
        reverseDuration: Duration(milliseconds: 300),
      ),
      builder: (BuildContext context) => CustomBottomSheet(
        title: title,
        height: height,
        onOpened: onOpened,
        child: child,
      ),
    );
  }
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.onOpened != null) {
      // addPostFrameCallback fires after the very first frame is laid out and
      // painted, meaning the sheet's text fields are in the tree and can safely
      // receive focus — no arbitrary timer needed.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onOpened?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double calculatedHeight =
        widget.height ??
            (widget.child is Scrollable || widget.child is SingleChildScrollView
                ? MediaQuery.of(context).size.height * 0.4
                : null) ??
            250.0;

    return Container(
      height: calculatedHeight,
      decoration: const BoxDecoration(
        color: AppColors.white,
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
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(widget.title!, style: context.txtTheme.labelLarge),
            ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.md,
              ),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}