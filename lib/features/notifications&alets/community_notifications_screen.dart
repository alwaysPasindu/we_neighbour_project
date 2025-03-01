import 'package:flutter/material.dart';
import 'package:we_neighbour/components/app_bar.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';

class CommunityNotificationsScreen extends StatelessWidget {
  const CommunityNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
          CustomAppBar(
            onBackPressed: () => Navigator.pop(context),
            isDarkMode: isDarkMode,
            ),
            Text(
              'Community\nNotifications',
              textAlign: TextAlign.center,
              style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  NotificationCard(
                    icon: "🎉",
                    message: "Community BBQ this weekend! Join us on Saturday at 4 PM.",
                    isDarkMode: isDarkMode,
                  ),
                  NotificationCard(
                    icon: "🏃",
                    message: "New yoga classes starting next week. Register at community center.",
                    isDarkMode: isDarkMode,
                  ),
                  NotificationCard(
                    icon: "📢",
                    message: "Monthly community meeting this Thursday at 7 PM.",
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Update NotificationCard to support dark mode
class NotificationCard extends StatelessWidget {
  final String icon;
  final String message;
  final bool isDarkMode;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.message,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }
}