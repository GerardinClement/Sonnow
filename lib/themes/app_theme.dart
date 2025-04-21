import 'package:flutter/material.dart';
import 'package:sonnow/themes/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: AppColors.primarySwatch,

      textTheme: Typography.material2021().black.copyWith(
        bodyLarge: const TextStyle(
          fontFamily: 'CooperHewitt',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: AppColors.text,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'CooperHewitt',
          fontWeight: FontWeight.bold,
          color: AppColors.text,
          fontSize: 22,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'CooperHewitt',
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.text,
        ),
      ).apply(
        fontFamily: 'CooperHewitt',
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.text,
          textStyle: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.text,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
    );
  }
}
