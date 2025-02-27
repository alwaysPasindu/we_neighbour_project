import 'package:flutter/material.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/screens/notifications_screen.dart';
import 'package:we_neighbour/screens/safety_alerts.dart';

class HeaderWidget extends StatelessWidget {
  final bool isDarkMode;

  const HeaderWidget({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color.fromARGB(255, 0, 18, 152) : const Color.fromARGB(255, 14, 105, 213),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            color: isDarkMode ? const Color.fromARGB(255, 0, 18, 152) : const Color.fromARGB(255, 14, 105, 213),
            height: MediaQuery.of(context).padding.top,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          isDarkMode 
                            ? 'assets/images/logo.png'
                            : 'assets/images/logo.png',
                          height: 90,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      'Hello, John...!',
                      style: AppTextStyles.greeting,
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SafetyAlertsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}