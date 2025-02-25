import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/screens/visitor_management_screen.dart';

// Screen imports
import 'screens/login_page.dart';
import 'screens/account_type_page.dart';
import 'screens/resident_signup_page.dart';
import 'screens/manager_signup_page.dart';
import 'screens/service_provider_signup_page.dart';
import 'screens/home_screen.dart';
import 'screens/event_calendar_screen.dart';
import 'screens/resident_profile_screen.dart';
import 'screens/manager_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/provider_home_page.dart';
import 'screens/company_profile_screen.dart';
import 'screens/service_page.dart';

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'We Neighbour',
          theme: ThemeData(
            primaryColor: AppColors.primary,
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: AppColors.background,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: Colors.grey[900],
            visualDensity: VisualDensity.adaptivePlatformDensity,
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
            '/home': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final userType = args is UserType ? args : UserType.resident;
              return HomeScreen(userType: userType);
            },

            '/settings': (context) => SettingsScreen(
              isDarkMode: themeProvider.isDarkMode,
              onThemeChanged: themeProvider.toggleTheme,
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
                  return MaterialPageRoute(builder: (_) => const MainPage());
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
  _MainPageState createState() => _MainPageState();
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