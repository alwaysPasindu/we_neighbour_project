import 'package:flutter/material.dart';
import 'package:we_neighbour/screens/visitor_management_screen.dart';
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
        icon: Image.asset('assets/icons/amenities.png', height: 28, width: 28),
        onTap: () {
          // TODO: Implement amenities booking navigation
        },
      ),
      FeatureItem(
        title: 'VISITOR MANAGEMENT',
        icon: Image.asset('assets/icons/visitor.png', height: 28, width: 28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VisitorManagementScreen()),
          );
        },
      ),
      FeatureItem(
        title: 'Apartment MAINTENANCE',
        icon: Image.asset('assets/icons/maintenance.png', height: 28, width: 28),
        onTap: () {
          // TODO: Implement maintenance navigation
        },
      ),
      FeatureItem(
        title: 'EVENT CALENDAR',
        icon: Image.asset('assets/icons/calendar.png', height: 28, width: 28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventCalendarScreen()),
          );
        },
      ),
      FeatureItem(
        title: 'BILLS',
        icon: Image.asset('assets/icons/bills.png', height: 28, width: 28),
        onTap: () {
          // TODO: Implement bills navigation
        },
      ),
      FeatureItem(
        title: 'Chats',
        icon: Image.asset('assets/icons/chat.png', height: 28, width: 28),
        onTap: () {
          // TODO: Implement chats navigation
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85, // Adjusted to accommodate the content
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          return _buildFeatureItem(features[index]);
        },
      ),
    );
  }

  Widget _buildFeatureItem(FeatureItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: item.icon,
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              item.title,
              style: AppTextStyles.featureTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}