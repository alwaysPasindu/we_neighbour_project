import 'package:flutter/material.dart';
import '../components/app_bar.dart';
import '../constants/colors.dart';
import 'management_notifications_screen.dart';
import 'community_notifications_screen.dart';

import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onBackPressed: () => Navigator.pop(context)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Notifications',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  _NotificationButton(
                    title: 'Management',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ManagementNotificationsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _NotificationButton(
                    title: 'Community',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CommunityNotificationsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Image.asset(
                'assets/we_neighbour_logo.jpeg', // Make sure to replace this with the correct path to your logo
                width: 80, // Adjust the width as needed
                height: 80, // Adjust the height as needed
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

  const _NotificationButton({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
