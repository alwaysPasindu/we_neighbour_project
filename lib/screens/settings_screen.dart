import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: AppTextStyles.greeting.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Settings List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSettingTile('Rate App', Icons.star_outline),
                  _buildSettingTile('Share App', Icons.share_outlined),
                  _buildSettingTile('Privacy Policy', Icons.lock_outline),
                  _buildSettingTile('Terms and Conditions', Icons.description_outlined),
                  _buildSettingTile('Cookies Policy', Icons.cookie_outlined),
                  _buildSettingTile('Contact', Icons.mail_outline),
                  _buildSettingTile('Feedback', Icons.chat_bubble_outline),
                  _buildSettingTile(
                    'Logout',
                    Icons.logout,
                    textColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, IconData icon, {Color? textColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, color: textColor ?? AppColors.textPrimary),
      title: Text(
        title,
        style: AppTextStyles.serviceTitle.copyWith(
          color: textColor ?? AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      onTap: () {
        // Handle tap for each setting
      },
    );
  }
}

