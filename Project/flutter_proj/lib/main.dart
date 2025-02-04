import 'package:flutter/material.dart';
import 'package:flutter_proj/pages/settings_screen.dart';
import 'package:flutter_proj/pages/settings_screen_light.dart';
import 'pages/profile_screen.dart';
import 'pages/account_selection_screen.dart';
import 'pages/manager_profile_screen.dart';
import 'pages/company_profile_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We-Neighbour App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF12284C),
      ),
      // home: const ProfileScreen(),
        //  home: const SettingsScreen(),
        // home: const SettingsScreenLight(),
      // home: const AccountSelectionScreen(),
      home: const ManagerProfileScreen(),
      // home: const CompanyProfileScreen(),
    );
  }
}