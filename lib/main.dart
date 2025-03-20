import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/event_calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
