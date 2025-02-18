import 'package:flutter/material.dart';
import '../widgets/feature_column.dart';
import '../widgets/custom_button.dart';

class EventCalendarScreen extends StatelessWidget {
  const EventCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button and logo
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/we_neighbour_logo.png',
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
            const Text(
              'Event Calendar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // White Card Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                          iconPath: 'assets/calendar_icon.png',
                          label: 'Google\nCalendar',
                          onTap: () {
                            // Handle Google Calendar tap
                          },
                        ),
                        FeatureColumn(
                          iconPath: 'assets/amenities_icon.png',
                          label: 'Book\nAmenities',
                          onTap: () {
                            // Handle Book Amenities tap
                          },
                        ),
                        FeatureColumn(
                          iconPath: 'assets/health_icon.png',
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
