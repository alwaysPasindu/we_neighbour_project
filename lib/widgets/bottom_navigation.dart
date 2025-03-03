import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../main.dart'; // Import this to use UserType

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final UserType userType;
  final bool isDarkMode;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userType,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDarkMode 
          ? AppColors.darkTextSecondary 
          : AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: isDarkMode 
            ? AppColors.darkTextSecondary 
            : AppColors.textSecondary,
        ),
        items: [
          _buildNavigationBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          _buildNavigationBarItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: 'Chat',
          ),
          _buildNavigationBarItem(
            icon: Icons.share_outlined,
            activeIcon: Icons.share,
            label: 'Resource',
          ),
          _buildNavigationBarItem(
            icon: Icons.build_outlined,
            activeIcon: Icons.build,
            label: 'Service',
          ),
          _buildNavigationBarItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }
}