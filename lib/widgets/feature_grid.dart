import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class FeatureItem {
  final String title;
  final String icon;
  final VoidCallback onTap;

  FeatureItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class FeatureGrid extends StatelessWidget {
  FeatureGrid({Key? key}) : super(key: key);

  final List<FeatureItem> features = [
    FeatureItem(
      title: 'AMENITIES BOOKING',
      icon: 'assets/icons/amenities.png', // Add your icons
      onTap: () {},
    ),
    FeatureItem(
      title: 'VISITOR MANAGEMENT',
      icon: 'assets/icons/visitor.png',
      onTap: () {},
    ),
    FeatureItem(
      title: 'EVENT CALENDAR',
      icon: 'assets/icons/calendar.png',
      onTap: () {},
    ),
    FeatureItem(
      title: 'Apartment MAINTENANCE',
      icon: 'assets/icons/maintenance.png',
      onTap: () {},
    ),
    FeatureItem(
      title: 'BILLS',
      icon: 'assets/icons/bills.png',
      onTap: () {},
    ),
    FeatureItem(
      title: 'Chats',
      icon: 'assets/icons/chat.png',
      onTap: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureItem(features[index]);
      },
    );
  }

  Widget _buildFeatureItem(FeatureItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              item.icon,
              height: 32,
              width: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: AppTextStyles.featureTitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
