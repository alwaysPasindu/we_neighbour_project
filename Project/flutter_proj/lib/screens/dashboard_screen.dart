import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.accentColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Good Morning, John...!',
                    style: AppTheme.titleStyle.copyWith(color: Colors.white)),
                const Icon(Icons.notifications, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureGrid(),
          const SizedBox(height: 20),
          _buildServiceCard('High-quality painting services', 'Painter'),
          _buildServiceCard('Expert plumbing services', 'ABC Company'),
          _buildServiceCard('Professional carpentry work', 'Carpenter'),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      'Amenities Booking',
      'Visitor Management',
      'Event Calendar',
      'Apartment Maintenance',
      'Bills',
      'Chats'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) => Column(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accentColor,
            radius: 30,
            child: const Icon(Icons.calendar_today, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(features[index], style: AppTheme.bodyStyle),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String description, String company) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ListTile(
        leading: const Icon(Icons.build, color: AppTheme.accentColor),
        title: Text(description),
        subtitle: Text(company),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
