import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/feature_column.dart';
import '../widgets/custom_button.dart';

class EventCalendarScreen extends StatelessWidget {
  const EventCalendarScreen({super.key});

  // Function to open Google Calendar
  Future<void> _openGoogleCalendar() async {
    // Google Calendar URL
    final Uri url = Uri.parse('https://calendar.google.com/');

    // Try to launch the URL
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

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
                        height: 100, // Adjust this value as needed
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
                          onTap: _openGoogleCalendar, // Use the function here
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
