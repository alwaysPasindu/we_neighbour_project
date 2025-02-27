import 'package:flutter/material.dart';
import 'package:we_neighbour/components/app_bar.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class ManagementNotificationsScreen extends StatelessWidget {
  const ManagementNotificationsScreen({super.key});

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
              'Management\nNotifications',
              textAlign: TextAlign.center,
              style: AppTextStyles.getGreetingStyle(isDarkMode),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  NotificationCard(
                    icon: "🔧",
                    message: "Notice: Scheduled electrical maintenance on floors 2-5 on 08.10.2024.",
                    isDarkMode: isDarkMode,
                  ),
                  NotificationCard(
                    icon: "📝",
                    message: "Please check the Noticeboard for parking regulations update.",
                    isDarkMode: isDarkMode,
                  ),
                  NotificationCard(
                    icon: "📊",
                    message: "Monthly utility bill ready for review. Due: 02.10.2024",
                    isDarkMode: isDarkMode,
                  ),
                  NotificationCard(
                    icon: "✔️",
                    message: "Maintenance request completed. Please provide feedback.",
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