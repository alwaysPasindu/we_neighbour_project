import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Base styles
  static const TextStyle greeting = TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle featureTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle getSubtitleStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle serviceTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Theme-aware style getters
  static TextStyle getGreetingStyle(bool isDarkMode) {
    return greeting.copyWith(
      color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 0, 0, 0),
    );
  }
  static TextStyle getNotificationStyle(bool isDarkMode) {
    return greeting.copyWith(
      color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 255, 255, 255),
    );
  }

  static TextStyle getFeatureTitleStyle(bool isDarkMode) {
    return featureTitle.copyWith(
      color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );
  }

  static TextStyle getServiceTitleStyle(bool isDarkMode) {
    return serviceTitle.copyWith(
      color: isDarkMode ? AppColors.darkTextPrimary : Colors.white,
    );
  }

  // Additional theme-aware styles
  static TextStyle getBodyTextStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
    );
  }

  static TextStyle getButtonTextStyle(bool isDarkMode) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isDarkMode ? AppColors.darkTextPrimary : Colors.white,
    );
  }
}