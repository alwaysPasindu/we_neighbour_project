import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12284C),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
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
                    'Notification',
                    Icons.notifications_none,
                    notificationsEnabled,
                    (value) => setState(() => notificationsEnabled = value),
                  ),
                  _buildSwitchTile(
                    'Light Mode',
                    Icons.dark_mode_outlined,
                    darkModeEnabled,
                    (value) => setState(() => darkModeEnabled = value),
                  ),
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
      leading: Icon(icon, color: textColor ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
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
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: Colors.white38,
      ),
    );
  }
}