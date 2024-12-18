import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text('John Doe',
                style: AppTheme.titleStyle.copyWith(fontSize: 20)),
            const SizedBox(height: 20),
            _buildInfoTile('Email', 'johndoe@gmail.com'),
            _buildInfoTile('Phone Number', '+94 71 234 3465'),
            _buildInfoTile('Apartment', '2/3 Lotus Residence Colombo 03'),
            const SizedBox(height: 40),
            _buildMenuItem(Icons.event, 'Event Participation'),
            _buildMenuItem(Icons.build, 'Maintenance Requests'),
            _buildMenuItem(Icons.settings, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white70)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: ListTile(
        tileColor: Colors.white12,
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
