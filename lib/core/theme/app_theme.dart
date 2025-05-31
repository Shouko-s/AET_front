import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // Основная цветовая схема
    primaryColor: ColorConstants.primaryColor,
    scaffoldBackgroundColor: ColorConstants.backgroundColor,
    colorScheme: ColorScheme.light(
      primary: ColorConstants.primaryColor,
      error: ColorConstants.errorColor,
    ),

    // Настройки AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: ColorConstants.backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: ColorConstants.textColor),
      titleTextStyle: TextStyle(
        color: ColorConstants.primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Настройки кнопок
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.primaryColor,
        foregroundColor: ColorConstants.buttonTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // Настройки OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: ColorConstants.primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    // Настройки текстовых полей
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorConstants.inputBackgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ColorConstants.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ColorConstants.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: ColorConstants.primaryColor),
      ),
    ),
  );
}
