import 'package:flutter/material.dart';
import '../components/app_bar.dart';
import '../components/dashboard_button.dart';
import '../constants/colors.dart';
import 'pending_tasks_screen.dart';
import 'notifications_screen.dart';
import 'visitor_log_screen.dart';
import 'residents_requests_screen.dart';
import 'reports_screen.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Manager\nDashboard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DashboardButton(
                      title: 'Pending Tasks',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PendingTasksScreen()),
                      ),
                    ),
                    DashboardButton(
                      title: 'Announcements',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      ),
                    ),
                    DashboardButton(
                      title: 'Visitor Log',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const VisitorLogScreen()),
                      ),
                    ),
                    DashboardButton(
                      title: 'Residents\' Requests',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResidentsRequestsScreen()),
                      ),
                    ),
                    DashboardButton(
                      title: 'Reports Section',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReportsScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

