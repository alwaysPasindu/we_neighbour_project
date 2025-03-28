import 'package:flutter/material.dart';
import '../components/app_bar.dart';
import '../constants/colors.dart';
import 'package:logger/logger.dart';

class PendingTasksScreen extends StatelessWidget {
  const PendingTasksScreen({super.key});

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
                    'Pending Tasks',
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
                itemCount: 8,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(index).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getTaskIcon(index),
                                  color: _getPriorityColor(index),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getTaskTitle(index),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getTaskDescription(index),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getPriorityColor(index).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _getPriorityText(index),
                                            style: TextStyle(
                                              color: _getPriorityColor(index),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: isDarkMode
                                              ? AppColors.darkTextSecondary
                                              : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _getDueDate(index),
                                          style: TextStyle(
                                            fontSize: 12,
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
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Handle mark as complete
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
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Mark as Complete',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  'View Details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add new task
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getTaskIcon(int index) {
    switch (index % 4) {
      case 0:
        return Icons.engineering;
      case 1:
        return Icons.security;
      case 2:
        return Icons.cleaning_services;
      default:
        return Icons.build;
    }
  }

  String _getTaskTitle(int index) {
    switch (index % 4) {
      case 0:
        return 'Maintenance Check';
      case 1:
        return 'Security Inspection';
      case 2:
        return 'Cleaning Service';
      default:
        return 'Repair Work';
    }
  }

  String _getTaskDescription(int index) {
    switch (index % 4) {
      case 0:
        return 'Regular maintenance check for Building A';
      case 1:
        return 'Monthly security system inspection';
      case 2:
        return 'Deep cleaning of common areas';
      default:
        return 'Fix reported issues in Block C';
    }
  }

  Color _getPriorityColor(int index) {
    switch (index % 3) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getPriorityText(int index) {
    switch (index % 3) {
      case 0:
        return 'High Priority';
      case 1:
        return 'Medium Priority';
      default:
        return 'Low Priority';
    }
  }

  String _getDueDate(int index) {
    final today = DateTime.now();
    final dueDate = today.add(Duration(days: index + 1));
    return '${dueDate.day}/${dueDate.month}/${dueDate.year}';
  }
}