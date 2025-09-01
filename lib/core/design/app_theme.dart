import 'package:flutter/material.dart';
import '../../../core/design/app_colors.dart';

class AppTheme {
  static ThemeData defaultThemeData = ThemeData(
    useMaterial3: true,
    //font family
    scaffoldBackgroundColor: AppColors.bgColor,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    iconTheme: const IconThemeData(opacity: 1, color: AppColors.primaryColor),
    fontFamily: 'satoshi',
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelBehavior: FloatingLabelBehavior.always,
      floatingLabelStyle: const TextStyle(
        color: AppColors.primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      labelStyle: const TextStyle(
        color: AppColors.primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.0),
      ),
      hintStyle: const TextStyle(
        color: AppColors.grey,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
      ),
    ),

    /// Floating action member ========>
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: AppColors.white,
      backgroundColor: AppColors.primaryColor,
      extendedTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),

      /// Button text ========>
      labelLarge: TextStyle(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.w700),

      /// Label for the text Form =====>
      labelMedium: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(
        color: AppColors.headlineText,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),

      /// ========> Appbar text &&  form hint text
      bodyMedium: TextStyle(color: AppColors.grey, fontSize: 16, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(
        color: AppColors.black,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ),
      titleMedium: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: AppColors.black, fontSize: 14, fontWeight: FontWeight.w700),

      /// Card title ======>
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    dividerColor: Colors.grey,
    dividerTheme: const DividerThemeData(color: Colors.grey),
  );
}
