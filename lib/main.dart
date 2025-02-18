import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/event_calendar_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We Neighbour',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor:
            const Color(0xFF0A1A3B), // Dark blue background
      ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/event-calendar': (context) => const EventCalendarScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
