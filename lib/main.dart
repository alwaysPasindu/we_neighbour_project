//main
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/event_calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error initializing Firebase: ${snapshot.error}');
            return const Center(child: Text('Failed to initialize Firebase'));
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return EventCalendarScreen();
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
