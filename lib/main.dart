import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/profile_screen.dart';
import 'pages/manager_profile_screen.dart';
import 'pages/company_profile_screen.dart';
import 'pages/settings_screen.dart';
import 'pages/rate_app_screen.dart';
import 'pages/share_app_screen.dart';
import 'pages/privacy_policy_screen.dart';
import 'pages/terms_conditions_screen.dart';
import 'pages/cookies_policy_screen.dart';
import 'pages/contact_screen.dart';
import 'pages/feedback_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We-Neighbour',
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        colorScheme: ColorScheme.light(
          primary: AppTheme.primaryColor,
          secondary: AppTheme.accentColor,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        colorScheme: ColorScheme.dark(
          primary: AppTheme.primaryColor,
          secondary: AppTheme.accentColor,
          background: const Color(0xFF12284C),
          surface: const Color(0xFF12284C),
        ),
        scaffoldBackgroundColor: const Color(0xFF12284C),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        // Add this to ensure all backgrounds are dark
        canvasColor: const Color(0xFF12284C),
        cardColor: const Color(0xFF1E3A64),
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/profile',
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/manager_profile': (context) => const ManagerProfileScreen(),
        '/company_profile': (context) => const CompanyProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/rate_app': (context) => const RateAppScreen(),
        '/share_app': (context) => const ShareAppScreen(),
        '/privacy_policy': (context) => const PrivacyPolicyScreen(),
        '/terms_conditions': (context) => const TermsConditionsScreen(),
        '/cookies_policy': (context) => const CookiesPolicyScreen(),
        '/contact': (context) => const ContactScreen(),
        '/feedback': (context) => const FeedbackScreen(),
      },
    );
  }
}

