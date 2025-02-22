import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                  _buildSwitchTile(
                    'Dark Mode',
                    Icons.dark_mode_outlined,
                    themeProvider.isDarkMode,
                    (value) => themeProvider.toggleTheme(value),
                    context,
                  ),
                  _buildSettingTile('Rate App', Icons.star_outline, context),
                  _buildSettingTile('Share App', Icons.share_outlined, context),
                  _buildSettingTile('Privacy Policy', Icons.lock_outline, context),
                  _buildSettingTile('Terms and Conditions', Icons.description_outlined, context),
                  _buildSettingTile('Cookies Policy', Icons.cookie_outlined, context),
                  _buildSettingTile('Contact', Icons.mail_outline, context),
                  _buildSettingTile('Feedback', Icons.chat_bubble_outline, context),
                  _buildSettingTile(
                    'Logout',
                    Icons.logout,
                    context,
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

  Widget _buildSettingTile(String title, IconData icon, BuildContext context, {Color? textColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, color: textColor ?? Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 16,
        ),
      ),
      onTap: () {
        // Handle tap for each setting
        switch (title) {
          case 'Rate App':
            // Implement rate app functionality
            break;
          case 'Share App':
            // Implement share app functionality
            break;
          case 'Logout':
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Implement logout functionality
                    },
                    child: const Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
            break;
          default:
            // Handle other settings
            break;
        }
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    BuildContext context,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}