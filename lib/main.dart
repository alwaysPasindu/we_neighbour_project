import 'package:flutter/material.dart';
import 'screens/event_calendar_screen.dart';

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
