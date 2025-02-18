import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/account_type_page.dart';
import 'screens/resident_signup_page.dart';
import 'screens/manager_signup_page.dart';
import 'screens/service_provider_signup_page.dart';
import 'screens/home_screen.dart';

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
        scaffoldBackgroundColor: Colors.white,
      ),
    routes: {
    '/': (context) => LoginPage(),
    '/account-type': (context) => AccountTypePage(),
    '/resident-signup': (context) => ResidentSignUpPage(),
    '/manager-signup': (context) => ManagerSignUpPage(),
    '/service-provider-signup': (context) => ServiceProviderSignUpPage(),
    '/home': (context) => HomeScreen(),
  },
      debugShowCheckedModeBanner: false,
    );
  }
}