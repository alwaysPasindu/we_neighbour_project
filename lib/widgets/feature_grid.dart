import 'package:flutter/material.dart';
import 'package:we_neighbour/features/chat/chat_list_page.dart';
import 'package:we_neighbour/features/maintenance/maintenance_screen.dart';
import '../features/visitor_management/visitor_management_screen.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../features/event_calendar/event_calendar_screen.dart';

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
  final bool isDarkMode;

  FeatureGrid({
    Key? key, 
    required this.isDarkMode,
  }) : super(key: key);

  late final List<FeatureItem> features;

  @override
  Widget build(BuildContext context) {
    features = [
      FeatureItem(
        title: 'Amenities Booking',
        icon: Image.asset(
          'assets/icons/amenities.png',    
          height: 28, 
          width: 28,
          // color: isDarkMode ? Colors.white : null,
        ),
        onTap: () {
          // TODO: Implement amenities booking navigation
        },
      ),
      FeatureItem(
        title: 'Visitor Management',
        icon: Image.asset(
          'assets/icons/visitor.png',
          height: 28, 
          width: 28,
          // color: isDarkMode ? Colors.white : null,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VisitorManagementScreen()),
          );
        },
      ),
      FeatureItem(
        title: 'Apartment Maintenance',
        icon: Image.asset(
          'assets/icons/maintenance.png',
          height: 28, 
          width: 28,
          // color: isDarkMode ? Colors.white : null,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
          );
        },
      ),
      FeatureItem(
        title: 'Event Calendar',
        icon: Image.asset(
          'assets/icons/calendar.png',
          height: 28, 
          width: 28,
          // color: isDarkMode ? null : null,
        ),
        onTap: () {
          // Navigator.push(
          //   // context,
          //   // MaterialPageRoute(builder: (context) => EventCalendarScreen()),
          // );
        },
      ),
      FeatureItem(
        title: 'Maintenance Request',
        icon: Image.asset(
          'assets/icons/maintenance.png',
          height: 28, 
          width: 28,
          // color: isDarkMode ? Colors.white : null,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MaintenanceScreen()),
          );
        },
      ),
      FeatureItem(
        title: 'Chats',
        icon: Image.asset(
          'assets/icons/chat.png',
          height: 28, 
          width: 28,
          // color: isDarkMode ? Colors.white : null,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatListPage()),
             );
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
              color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
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
              style: isDarkMode 
                ? AppTextStyles.getFeatureTitleStyle(true)
                : AppTextStyles.featureTitle,
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