import 'package:flutter/material.dart';

class SettingsScreenLight extends StatefulWidget {
  const SettingsScreenLight({Key? key}) : super(key: key);

  @override
  State<SettingsScreenLight> createState() => _SettingsScreenLightState();
}

class _SettingsScreenLightState extends State<SettingsScreenLight> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.black87,
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
                    'Dark Mode',
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
      leading: Icon(icon, color: textColor ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
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
      leading: Icon(icon, color: Colors.black87),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
        activeTrackColor: Colors.blue.withOpacity(0.5),
      ),
    );
  }
}