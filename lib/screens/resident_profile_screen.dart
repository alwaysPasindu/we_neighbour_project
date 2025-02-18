import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class ResidentProfileScreen extends StatelessWidget {
  const ResidentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                _buildProfileImage(),
                const SizedBox(height: 16),
                Text('John Doe', style: AppTextStyles.greeting),
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

  Widget _buildProfileImage() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          backgroundImage: const AssetImage('assets/images/profileImg.avif'),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary,
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

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.featureTitle),
        const SizedBox(height: 8),
        Text(value, style: AppTextStyles.serviceTitle.copyWith(color: AppColors.textPrimary)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: AppColors.textSecondary),
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
          border: Border.all(color: AppColors.textSecondary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(title, style: AppTextStyles.serviceTitle.copyWith(color: AppColors.textPrimary)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}

