import 'package:flutter/material.dart';
import 'package:safety_alerts/screens/safety_alerts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF571F1F),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SafetyAlertsScreen(),
      },
    );
  }
}
