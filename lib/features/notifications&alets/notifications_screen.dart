import 'package:flutter/material.dart';
import 'package:we_neighbour/components/app_bar.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'management_notifications_screen.dart';
import 'community_notifications_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
              'Notifications',
              style: AppTextStyles.getGreetingStyle(isDarkMode),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                children: [
                  _NotificationButton(
                    title: 'Management',
                    isDarkMode: isDarkMode,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagementNotificationsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _NotificationButton(
                    title: 'Community',
                    isDarkMode: isDarkMode,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CommunityNotificationsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: Image.asset(
                isDarkMode 
                  ? 'assets/images/logo.png'
                  : 'assets/images/logo_dark.png',
                width: 80,
                height: 90,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isDarkMode;

  const _NotificationButton({
    required this.title,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode 
            ? AppColors.primary 
            : const Color.fromARGB(255, 0, 18, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isDarkMode ? 2 : 0,
        ),
        child: Text(
          title,
          style: AppTextStyles.getButtonTextStyle(isDarkMode),
        ),
      ),
    );
  }
}