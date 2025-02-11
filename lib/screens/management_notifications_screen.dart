import 'package:flutter/material.dart';
import '../components/app_bar.dart';
import '../constants/colors.dart';

class ManagementNotificationsScreen extends StatelessWidget {
  const ManagementNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(onBackPressed: () => Navigator.pop(context)),
            const Text(
              'Management\nNotifications',
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
                    icon: "🔧",
                    message: "Notice: Scheduled electrical maintenance on floors 2-5 on 08.10.2024.",
                  ),
                  NotificationCard(
                    icon: "📝",
                    message: "Please check the Noticeboard for parking regulations update.",
                  ),
                  NotificationCard(
                    icon: "📊",
                    message: "Monthly utility bill ready for review. Due: 02.10.2024",
                  ),
                  NotificationCard(
                    icon: "✔️",
                    message: "Maintenance request completed. Please provide feedback.",
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

  const NotificationCard({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}