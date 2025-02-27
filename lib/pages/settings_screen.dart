import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/logout_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
      ),
      onTap: () {
        switch (title) {
          case 'Rate App':
            Navigator.pushNamed(context, '/rate_app');
            break;
          case 'Share App':
            Navigator.pushNamed(context, '/share_app');
            break;
          case 'Privacy Policy':
            Navigator.pushNamed(context, '/privacy_policy');
            break;
          case 'Terms and Conditions':
            Navigator.pushNamed(context, '/terms_conditions');
            break;
          case 'Cookies Policy':
            Navigator.pushNamed(context, '/cookies_policy');
            break;
          case 'Contact':
            Navigator.pushNamed(context, '/contact');
            break;
          case 'Feedback':
            Navigator.pushNamed(context, '/feedback');
            break;
          case 'Logout':
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return LogoutDialog(
                  onLogout: () {
                    // Handle logout functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('You have been logged out'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Navigate to login screen
                    Navigator.of(context).pushNamedAndRemoveUntil('/profile', (route) => false);
                  },
                );
              },
            );
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSwitchTile(
            'Dark Mode',
            Icons.dark_mode_outlined,
            themeProvider.isDarkMode,
            (value) => themeProvider.toggleTheme(value),
            context,
          ),
          _buildSettingTile('Rate App', Icons.star, context),
          _buildSettingTile('Share App', Icons.share, context),
          _buildSettingTile('Privacy Policy', Icons.privacy_tip, context),
          _buildSettingTile('Terms and Conditions', Icons.description, context),
          _buildSettingTile('Cookies Policy', Icons.cookie, context),
          _buildSettingTile('Contact', Icons.contact_mail, context),
          _buildSettingTile('Feedback', Icons.feedback, context),
          _buildSettingTile('Logout', Icons.logout, context, textColor: Colors.red),
        ],
      ),
    );
  }
}

