import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WE Neighbour',
      theme: ThemeData(
        primaryColor: const Color(0xFF0A1A3B),
        scaffoldBackgroundColor: const Color(0xFF0A1A3B),
      ),
      home: const EventCalendarScreen(),
    );
  }
}

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
                      // Handle back navigation
                    },
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'WE\nNEIGHBOUR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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
                        _buildFeatureColumn(
                          'assets/calendar_icon.png',
                          'Google\nCalendar',
                        ),
                        _buildFeatureColumn(
                          'assets/amenities_icon.png',
                          'Book\nAmenities',
                        ),
                        _buildFeatureColumn(
                          'assets/health_icon.png',
                          'Health &\nWellness',
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Buttons
                    _buildButton('Add / Remove Event'),
                    const SizedBox(height: 16),
                    _buildButton('Manage RSVPs'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureColumn(String iconPath, String label) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset(
            iconPath,
            width: 40,
            height: 40,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A3B),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
