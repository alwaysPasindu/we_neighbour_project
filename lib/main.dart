import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Calendar',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A2B4A),
        scaffoldBackgroundColor: const Color(0xFF1A2B4A),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'WE\nNEIGHBOUR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Event Calendar Title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Event Calendar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Main Content Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Grid of options
                    SizedBox(
                      height: 180, // Fixed height for the grid
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Expanded(
                            child: FeatureCard(
                              icon: 'assets/calendar.png',
                              title: 'Google\nCalendar',
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: FeatureCard(
                              icon: 'assets/book.png',
                              title: 'Book\nAmenities',
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: FeatureCard(
                              icon: 'assets/health.png',
                              title: 'Health &\nWellness',
                              color: Colors.lightBlue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    // Buttons
                    ActionButton(
                      title: 'Add / Remove Event',
                      onPressed: () {},
                    ),
                    const SizedBox(height: 12),
                    ActionButton(
                      title: 'Manage RSVPs',
                      onPressed: () {},
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

class FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final Color color;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset(
            icon,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A2B4A),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
