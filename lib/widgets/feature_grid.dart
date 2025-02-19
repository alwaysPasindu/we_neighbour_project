import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../screens/event_calendar_screen.dart';

class FeatureItem {
  final String title;
  final Widget icon;
  final VoidCallback onTap;

  FeatureItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class FeatureGrid extends StatelessWidget {
  FeatureGrid({Key? key}) : super(key: key);

  late final List<FeatureItem> features;

  @override
  Widget build(BuildContext context) {
    features = [
      FeatureItem(
        title: 'AMENITIES BOOKING',
        icon: Image.asset('assets/icons/amenities.png', height: 32, width: 32),
        onTap: () {
          // TODO: Implement amenities booking navigation
        },
      ),
      FeatureItem(
        title: 'VISITOR MANAGEMENT',
        icon: Image.asset('assets/icons/visitor.png', height: 32, width: 32),
        onTap: () {
          // TODO: Implement visitor management navigation
        },
      ),
      FeatureItem(
        title: 'Apartment MAINTENANCE',
        icon: Image.asset('assets/icons/maintenance.png', height: 32, width: 32),
        onTap: () {
          // TODO: Implement maintenance navigation
        },
      ),
      FeatureItem(
        title: 'EVENT CALENDAR',
        icon: Image.asset('assets/icons/calendar.png', height: 32, width: 32),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventCalendarScreen()),
          );
        },
      ),
      FeatureItem(
        title: 'BILLS',
        icon: Image.asset('assets/icons/bills.png', height: 32, width: 32),
        onTap: () {
          // TODO: Implement bills navigation
        },
      ),
      FeatureItem(
        title: 'Chats',
        icon: Image.asset('assets/icons/chat.png', height: 32, width: 32),
        onTap: () {
          // TODO: Implement chats navigation
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(30),
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
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: item.icon,
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