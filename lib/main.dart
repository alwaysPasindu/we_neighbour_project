import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/account_selection_screen.dart';
import 'pages/profile_screen.dart';
import 'pages/profile_screen_light.dart';
import 'pages/manager_profile_screen.dart';
import 'pages/manager_profile_screen_light.dart';
import 'pages/company_profile_screen.dart';
import 'pages/company_profile_screen_light.dart';
import 'pages/settings_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We-Neighbour App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppTheme.primaryColor,
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const AccountSelectionScreen(),
        '/profile': (context) =>
            themeProvider.isDarkMode ? const ProfileScreen() : const ProfileScreenLight(),
        '/manager_profile': (context) => themeProvider.isDarkMode
            ? const ManagerProfileScreen()
            : const ManagerProfileScreenLight(),
        '/company_profile': (context) => themeProvider.isDarkMode
            ? const CompanyProfileScreen()
            : const CompanyProfileScreenLight(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
