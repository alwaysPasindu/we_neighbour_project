import 'package:flutter/material.dart';
import '../components/app_bar.dart';
import '../constants/colors.dart';
import 'package:logger/logger.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Logger logger = Logger(); // Added logger instance (not used yet)

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onBackPressed: () => Navigator.pop(context),
              isDarkMode: isDarkMode,
            ),
            Padding(
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
                  Text(
                    'Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16), // Fixed typo: 'custom' to 'bottom'
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.grey.withValues(alpha: 0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getReportIcon(index),
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getReportTitle(index),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Last updated: ${_getLastUpdated(index)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(index).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatus(index),
                                  style: TextStyle(
                                    color: _getStatusColor(index),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Handle view report action
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.grey.shade50,
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.bar_chart,
                                  size: 16,
                                  color: isDarkMode
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_getDataPoints(index)} data points',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'View Report',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getReportIcon(int index) {
    switch (index) {
      case 0:
        return Icons.security;
      case 1:
        return Icons.people;
      case 2:
        return Icons.engineering;
      case 3:
        return Icons.attach_money;
      default:
        return Icons.assessment;
    }
  }

  String _getReportTitle(int index) {
    switch (index) {
      case 0:
        return 'Security Report';
      case 1:
        return 'Resident Activity';
      case 2:
        return 'Maintenance Summary';
      case 3:
        return 'Financial Overview';
      default:
        return 'General Analytics';
    }
  }

  String _getLastUpdated(int index) {
    return 'Today, ${8 + index}:00 AM';
  }

  String _getStatus(int index) {
    switch (index) {
      case 0:
        return 'Updated';
      case 1:
        return 'Live';
      case 2:
        return 'Pending';
      default:
        return 'Available';
    }
  }

  Color _getStatusColor(int index) {
    switch (index) {
      case 0:
        return Colors.green;
      case 1:
        return AppColors.primary;
      case 2:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getDataPoints(int index) {
    return '${(index + 1) * 124}';
  }
}