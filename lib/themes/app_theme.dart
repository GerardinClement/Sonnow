import 'package:flutter/material.dart';
import 'package:sonnow/app.dart';
import 'package:sonnow/themes/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: AppColors.primarySwatch,
      scaffoldBackgroundColor: AppColors.background,

      textTheme: Typography.material2021().black
          .copyWith(
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
          )
          .apply(
            fontFamily: 'CooperHewitt',
            bodyColor: AppColors.text,
            displayColor: AppColors.text,
          ),
      // Personnalisation du TextField (pour la barre de recherche)
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.primary.withOpacity(0.5),
        filled: true,
        hintStyle: TextStyle(color: Colors.white60),
        prefixIconColor: Colors.white70,
        suffixIconColor: Colors.white70,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.white24),
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.background.withAlpha(250),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        modalBarrierColor: Colors.black54,
      ),

      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white,
        subtitleTextStyle: TextStyle(color: Colors.white70, fontSize: 14),
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
