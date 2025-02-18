import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'screens/settings_screen.dart';
import 'constants/colors.dart';

// Enum to represent user types
enum UserType { resident, manager, serviceProvider }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void toggleTheme(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We Neighbour',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.grey[900],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/account-type': (context) => const AccountTypePage(),
        '/resident-signup': (context) => const ResidentSignUpPage(),
        '/manager-signup': (context) => const ManagerSignUpPage(),
        '/service-provider-signup': (context) => const ServiceProviderSignUpPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final userType = args is UserType ? args : UserType.resident;
          return HomeScreen(userType: userType);
        },
        '/event-calendar': (context) => const EventCalendarScreen(),
        '/settings': (context) => SettingsScreen(
          isDarkMode: _isDarkMode,
          onThemeChanged: toggleTheme,
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          final args = settings.arguments;
          final userType = args is UserType ? args : UserType.resident;
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

