import 'package:flutter/material.dart';
import 'package:we_neighbour/components/app_bar.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class EventCalendarScreen extends StatelessWidget {
  const EventCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode 
        ? AppColors.darkBackground 
        : const Color.fromARGB(255, 0, 18, 152),
      body: SafeArea(
        child: Column(
          children: [
        CustomAppBar(
          onBackPressed: () => Navigator.pop(context),
        isDarkMode: isDarkMode,  // Pass isDarkMode to CustomAppBar
        ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Event Calendar',
                style: AppTextStyles.getNotificationStyle(isDarkMode),
              
              ),
            ),
            const SizedBox(height: 30),

            // Card Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icons Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FeatureColumn(
                          iconPath: 'assets/images/calendar_icon.png',
                          label: 'Google\nCalendar',
                          isDarkMode: isDarkMode,
                          onTap: () {
                            // Handle Google Calendar tap
                          },
                        ),
                        FeatureColumn(
                          iconPath: 'assets/images/amenities_icon.png',
                          label: 'Book\nAmenities',
                          isDarkMode: isDarkMode,
                          onTap: () {
                            // Handle Book Amenities tap
                          },
                        ),
                        FeatureColumn(
                          iconPath: 'assets/images/health_icon.png',
                          label: 'Health &\nWellness',
                          isDarkMode: isDarkMode,
                          onTap: () {
                            // Handle Health & Wellness tap
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Buttons
                    CustomButton(
                      text: 'Add / Remove Event',
                      isDarkMode: isDarkMode,
                      onPressed: () {
                        // Handle Add/Remove Event
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Manage RSVPs',
                      isDarkMode: isDarkMode,
                      onPressed: () {
                        // Handle Manage RSVPs
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Update FeatureColumn widget
class FeatureColumn extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final bool isDarkMode;

  const FeatureColumn({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 50,
            height: 50,
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          const SizedBox(height: 30),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.getFeatureTitleStyle(isDarkMode),
          ),
        ],
      ),
    );
  }
}

// Update CustomButton widget
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDarkMode;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkMode 
            ? AppColors.primary 
            : const Color.fromARGB(255, 0, 18, 152),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.darkTextPrimary : Colors.white,
          ),
        ),
      ),
    );
  }
}