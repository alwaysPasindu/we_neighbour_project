import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF12284C) : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: isDarkMode ? const Color(0xFF1E3A64) : AppTheme.accentColor,
                      backgroundImage: const AssetImage('assets/images/profileImg.avif'),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E3A64) : AppTheme.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: isDarkMode ? Colors.white70 : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'John Doe',
                  style: AppTheme.titleStyle.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 32),
                _buildInfoField('Email', 'johndoe@gmail.com', isDarkMode),
                _buildInfoField('Phone Number', '+94 71 234 3465', isDarkMode),
                _buildInfoField('Apartment', '2/3 Lotus Residence Colombo 03', isDarkMode),
                const SizedBox(height: 40),
                _buildOption('Event Participation', Icons.event, isDarkMode),
                const SizedBox(height: 16),
                _buildOption('Maintenance Requests', Icons.build, isDarkMode),
                const SizedBox(height: 16),
                _buildOption(
                  'Settings',
                  Icons.settings,
                  isDarkMode,
                  onTap: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: isDarkMode ? Colors.white24 : Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOption(String title, IconData icon, bool isDarkMode, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: isDarkMode ? Colors.white24 : Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDarkMode ? Colors.white : AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: isDarkMode ? Colors.white : Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

