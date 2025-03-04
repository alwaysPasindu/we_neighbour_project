import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/screens/provider/provider_profile_screen.dart';
import 'package:we_neighbour/screens/maintenance_screen.dart'; // Add this import

// Screen imports
import 'screens/login_page.dart';
import 'screens/account_type_page.dart';
import 'screens/resident_signup_page.dart';
import 'screens/manager_signup_page.dart';
import 'screens/provider/provider_signup_page.dart';
import 'screens/home_screen.dart';
import 'screens/resident_profile_screen.dart';
import 'screens/manager_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/provider/provider_home_page.dart';
import 'screens/provider/service_page.dart';

// Provider and Constants
import 'providers/theme_provider.dart';
import 'constants/colors.dart';
import 'widgets/provider_bottom_navigation.dart';

enum UserType { resident, manager, serviceProvider }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDarkMode: isDarkMode),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'We Neighbour',
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: Colors.blue,
            ),
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              secondary: Colors.blue,
            ),
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: Colors.grey[900],
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/account-type': (context) => const AccountTypePage(),
            '/resident-signup': (context) => const ResidentSignUpPage(),
            '/manager-signup': (context) => const ManagerSignUpPage(),
            '/service-provider-signup': (context) => const ServiceProviderSignUpPage(),
            '/provider-home': (context) => const MainPage(),
            '/service': (context) => const ServicesPage(),
            '/login': (context) => const LoginPage(),
            '/maintenance': (context) => const MaintenanceScreen(), // Add this route
            '/home': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final userType = args is UserType ? args : UserType.resident;
              return HomeScreen(userType: userType);
            },
            '/settings': (context) => const SettingsScreen(),
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
                  return MaterialPageRoute(builder: (_) => const CompanyProfileScreen());
              }
            }
            return null;
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProviderHomePage(),
    const ServicesPage(),
    const CompanyProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}