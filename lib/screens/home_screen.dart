import 'package:flutter/material.dart';
import '../widgets/feature_column.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          AssetImage('assets/images/profile_picture.png'),
                    ),
                  ],
                ),
              ),

              // Welcome Text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Welcome, John!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Feature Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  FeatureColumn(
                    iconPath: 'assets/images/calendar_icon.png',
                    label: 'Event\nCalendar',
                    onTap: () {
                      Navigator.pushNamed(context, '/event-calendar');
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
                  // Add more FeatureColumn widgets for other features
                ],
              ),

              // Add more sections as needed for the home screen
            ],
          ),
        ),
      ),
    );
  }
}
