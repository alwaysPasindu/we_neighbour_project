import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/app_bar.dart';
import '../constants/colors.dart';
import 'pending_tasks_screen.dart';
import '../features/notifications&alets/notifications_screen.dart';
// import 'visitor_log_screen.dart';
import 'residents_requests_screen.dart';
import 'reports_screen.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(isDarkMode: isDarkMode),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manager Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back, Manager',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode 
                            ? AppColors.darkTextSecondary 
                            : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(16),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                crossAxisCount: 2,
                children: [
                  _buildDashboardCard(
                    context: context,
                    title: 'Pending Tasks',
                    icon: Icons.task_alt,
                    color: Colors.orange,
                    isDarkMode: isDarkMode,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PendingTasksScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context: context,
                    title: 'Announcements',
                    icon: Icons.campaign,
                    color: Colors.blue,
                    isDarkMode: isDarkMode,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context: context,
                    title: 'Visitor Log',
                    icon: Icons.how_to_reg,
                    color: Colors.green,
                    isDarkMode: isDarkMode,
                    onTap: () {
                      // Uncomment when VisitorLogScreen is ready
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const VisitorLogScreen()),
                      // );
                    },
                  ),
                  _buildDashboardCard(
                    context: context,
                    title: 'Residents\' Requests',
                    icon: Icons.people,
                    color: Colors.purple,
                    isDarkMode: isDarkMode,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ResidentsRequestsScreen()),
                    ),
                  ),
                  _buildDashboardCard(
                    context: context,
                    title: 'Reports Section',
                    icon: Icons.assessment,
                    color: AppColors.primary,
                    isDarkMode: isDarkMode,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}