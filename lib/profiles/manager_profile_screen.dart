import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../providers/theme_provider.dart';

class ManagerProfileScreen extends StatelessWidget {
  const ManagerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildProfileImage(isDarkMode),
                    const SizedBox(height: 16),
                    Text(
                      'John Doe',
                      style: AppTextStyles.greeting.copyWith(
                        color: isDarkMode ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoField(
                      'Email',
                      'johndoe@gmail.com',
                      isDarkMode,
                    ),
                    _buildInfoField(
                      'Phone Number',
                      '+94 71 234 3465',
                      isDarkMode,
                    ),
                    _buildInfoField(
                      'Apartment',
                      '2/3 Lotus Residence Colombo 03',
                      isDarkMode,
                    ),
                    const Spacer(),
                    _buildOption(
                      'Settings',
                      Icons.settings,
                      isDarkMode: isDarkMode,
                      onTap: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(bool isDarkMode) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: isDarkMode ? const Color(0xFF004CFF) : AppColors.primary,
          backgroundImage: const AssetImage('assets/images/profileImg.avif'),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF004CFF) : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoField(String label, String value, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.featureTitle.copyWith(
            color: isDarkMode ? Colors.grey[400] : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.serviceTitle.copyWith(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(
            color: isDarkMode ? Colors.grey[800] : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOption(
    String title,
    IconData icon, {
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : AppColors.textSecondary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDarkMode ? const Color(0xFF004CFF) : AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.serviceTitle.copyWith(
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.grey[600] : AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}