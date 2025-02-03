import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class ProfileScreenLight extends StatelessWidget {
  const ProfileScreenLight({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background
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
                      backgroundColor: Colors.blue[100],
                      child: Icon(Icons.person, size: 60, color: Colors.blue[800]),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'John Doe',
                  style: AppTheme.titleStyle.copyWith(fontSize: 24, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                _buildInfoField('Email', 'johndoe@gmail.com'),
                _buildInfoField('Phone Number', '+94 71 234 3465'),
                _buildInfoField('Apartment', '2/3 Lotus Residence Colombo 03'),
                const SizedBox(height: 40),
                _buildOption('Event Participation', Icons.event),
                const SizedBox(height: 16),
                _buildOption('Maintenance Requests', Icons.build),
                const SizedBox(height: 16),
                _buildOption(
                  'Settings',
                  Icons.settings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
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

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Colors.grey[300]),
        ),
      ],
    );
  }

  Widget _buildOption(String title, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[800]),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.blue[800], size: 16),
          ],
        ),
      ),
    );
  }
}

