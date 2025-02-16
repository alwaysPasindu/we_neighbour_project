import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/settings_screen.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We-Neighbour App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.accentColor),
        scaffoldBackgroundColor: AppTheme.backgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        primaryColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.accentColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppTheme.primaryColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
        primaryColor: AppTheme.accentColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      themeMode: themeProvider.themeMode,
      home: const SettingsScreen(),
    );
  }
}

