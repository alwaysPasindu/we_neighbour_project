import 'package:flutter/material.dart';
import '../components/app_bar.dart';
import '../constants/colors.dart';
import 'management_notifications_screen.dart'; // Import this to use NotificationCard

class CommunityNotificationsScreen extends StatelessWidget {
  const CommunityNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onBackPressed: () => Navigator.pop(context)),
            const Text(
              'Community\nNotifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: const [
                  NotificationCard(
                    icon: "🎉",
                    message: "Community BBQ this weekend! Join us on Saturday at 4 PM.",
                  ),
                  NotificationCard(
                    icon: "🏃",
                    message: "New yoga classes starting next week. Register at community center.",
                  ),
                  NotificationCard(
                    icon: "📢",
                    message: "Monthly community meeting this Thursday at 7 PM.",
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