import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/account_type_page.dart';
import 'screens/resident_signup_page.dart';
import 'screens/manager_signup_page.dart';
import 'screens/service_provider_signup_page.dart';
import 'screens/home_screen.dart';
import 'screens/event_calendar_screen.dart';
import 'screens/resident_profile_screen.dart';
import 'screens/manager_profile_screen.dart';
import 'screens/service_provider_profile_screen.dart';
import 'constants/colors.dart';

// Enum to represent user types
enum UserType { resident, manager, serviceProvider }

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
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/account-type': (context) => const AccountTypePage(),
        '/resident-signup': (context) => const ResidentSignUpPage(),
        '/manager-signup': (context) => const ManagerSignUpPage(),
        '/service-provider-signup': (context) => const ServiceProviderSignUpPage(),
        '/home': (context) => const HomeScreen(),
        '/event-calendar': (context) => const EventCalendarScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          final UserType userType = settings.arguments as UserType;
          switch (userType) {
            case UserType.resident:
              return MaterialPageRoute(builder: (_) => const ResidentProfileScreen());
            case UserType.manager:
              return MaterialPageRoute(builder: (_) => const ManagerProfileScreen());
            case UserType.serviceProvider:
              return MaterialPageRoute(builder: (_) => const ServiceProviderProfileScreen());
          }
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

