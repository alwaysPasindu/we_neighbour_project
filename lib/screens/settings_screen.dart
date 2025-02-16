import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
                    style: AppTheme.titleStyle.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.primaryColor,
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
                    (value) => themeProvider.toggleTheme(),
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
        style: AppTheme.bodyStyle.copyWith(
          color: textColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      onTap: () {
        // Handle tap for each setting
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
        style: AppTheme.bodyStyle.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.accentColor,
      ),
    );
  }
}

