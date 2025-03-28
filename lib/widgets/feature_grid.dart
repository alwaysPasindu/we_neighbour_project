import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/features/event_calendar/book_amenities_screen.dart';
import 'package:we_neighbour/features/event_calendar/event_calendar_screen.dart';
import 'package:we_neighbour/features/maintenance/maintenance_screen.dart';
import 'package:we_neighbour/screens/manager_maintenance_screen.dart';
import '../features/visitor_management/visitor_management_screen.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

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

  const FeatureGrid({
    super.key,
    required this.isDarkMode,
  });

  Future<Map<String, dynamic>> _getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'isManager': prefs.getString('userRole')?.toLowerCase() == 'manager',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getAuthData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: isDarkMode ? Colors.white70 : const Color(0xFF0E69D5),
            ),
          );
        }

        final String? token = snapshot.data!['token'] as String?;
        final bool isManager = snapshot.data!['isManager'] as bool;

        if (token == null) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF212130) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05) ,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 20,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF0E69D5),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Please log in to access features',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final features = [
          FeatureItem(
            title: 'Amenities Booking',
            icon: Image.asset('assets/icons/amenities.png', height: 28, width: 28),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookAmenitiesScreen()),
              );
            },
          ),
          FeatureItem(
            title: 'Visitor Management',
            icon: Image.asset('assets/icons/visitor.png', height: 28, width: 28),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VisitorManagementScreen()),
              );
            },
          ),
          FeatureItem(
            title: isManager ? 'Pending Maintenance' : 'Apartment Maintenance',
            icon: Image.asset('assets/icons/maintenance.png', height: 28, width: 28),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => isManager
                      ? ManagerMaintenanceScreen(authToken: token)
                      : MaintenanceScreen(authToken: token, isManager: false),
                ),
              );
            },
          ),
          FeatureItem(
            title: 'Event Calendar',
            icon: Image.asset('assets/icons/calendar.png', height: 28, width: 28),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventCalendarScreen()),
              );
            },
          ),
          if (!isManager)
            FeatureItem(
              title: 'Maintenance Request',
              icon: Image.asset('assets/icons/maintenance.png', height: 28, width: 28),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaintenanceScreen(authToken: token, isManager: false),
                  ),
                );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 16, bottom: 12),
                child: Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  return _buildFeatureItem(features[index]);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(FeatureItem item) {
    final Color primaryColor = isDarkMode ? const Color(0xFF0E69D5) : const Color(0xFF0E69D5);
    
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? const Color(0xFF1A1A28)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.05) 
                    : Colors.grey.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: item.icon,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              item.title,
              style: isDarkMode
                  ? AppTextStyles.getFeatureTitleStyle(true).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    )
                  : AppTextStyles.featureTitle.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
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