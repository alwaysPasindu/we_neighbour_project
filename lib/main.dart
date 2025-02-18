import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/account_type_page.dart';
import 'screens/resident_signup_page.dart';
import 'screens/manager_signup_page.dart';
import 'screens/service_provider_signup_page.dart';
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
        scaffoldBackgroundColor: const Color(0xFF0A1A3B), // Dark blue background
      ),
      routes: {
        '/': (context) => const LoginPage(),
        '/account-type': (context) => const AccountTypePage(),
        '/resident-signup': (context) => const ResidentSignUpPage(),
        '/manager-signup': (context) => const ManagerSignUpPage(),
        '/service-provider-signup': (context) => const ServiceProviderSignUpPage(),
        '/home': (context) => const HomeScreen(),
        '/event-calendar': (context) => const EventCalendarScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

