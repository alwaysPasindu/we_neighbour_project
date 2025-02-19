import 'package:flutter/material.dart';
import '../widgets/feature_column.dart';
import '../widgets/custom_button.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class EventCalendarScreen extends StatelessWidget {
  const EventCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 18, 152),
      body: SafeArea(

        child: Column(
          children: [
            // Back button and logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Event Calendar Text
            Text(
              'Event Calendar',
              style: AppTextStyles.greeting.copyWith(color: const Color.fromARGB(255, 255, 255, 255)),
            ),

            const SizedBox(height: 30),

            // White Card Container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
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
                          onTap: () {
                            // Handle Google Calendar tap
                          },
                        ),
                        FeatureColumn(
                          iconPath: 'assets/images/amenities_icon.png',
                          label: 'Book\nAmenities',
                          onTap: () {
                            // Handle Book Amenities tap
                          },
                        ),
                        FeatureColumn(
                          iconPath: 'assets/images/health_icon.png',
                          label: 'Health &\nWellness',
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
                      onPressed: () {
                        // Handle Add/Remove Event
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Manage RSVPs',
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