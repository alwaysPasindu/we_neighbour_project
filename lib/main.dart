import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/chat/chat_list_page.dart';
import 'features/resource_share/resource_sharing_page.dart';
import 'package:we_neighbour/profiles/provider_profile_screen.dart';

// Screen imports
import 'login&signup/login_page.dart';
import 'login&signup/account_type_page.dart';
import 'login&signup/resident_signup_page.dart';
import 'login&signup/manager_signup_page.dart';
import 'login&signup/provider_signup_page.dart';
import 'home/home_screen.dart';
import 'profiles/resident_profile_screen.dart';
import 'profiles/manager_profile_screen.dart';
import 'settings/settings_screen.dart';
import 'home/provider_home_page.dart';
import 'features/services/service_page.dart';

// Provider and Constants
import 'providers/theme_provider.dart';
import 'constants/colors.dart';
import 'widgets/bottom_navigation.dart';

enum UserType { resident, manager, serviceProvider }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              secondary: Colors.blue,
            ),
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            // Add other light theme customizations
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              secondary: Colors.blue,
            ),
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: Colors.grey[900],
            visualDensity: VisualDensity.adaptivePlatformDensity,
            // Add other dark theme customizations
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
              '/service-provider-signup': (context) =>
                  const ServiceProviderSignUpPage(),
              '/provider-home': (context) => const MainPage(),
              '/service': (context) => const ServicesPage(),
              // '/chat': (context) => const ChatListPage(),
              '/resource': (context) => const ResourceSharingPage(),
              '/login': (context) => const LoginPage(),
              '/home': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final userType = args is UserType ? args : UserType.resident;
                return HomeScreen(userType: userType);
              },
              '/settings': (context) =>
                  const SettingsScreen(), // Updated to use const constructor
          },

          onGenerateRoute: (settings) {
            if (settings.name == '/profile') {
              final args = settings.arguments;
              final userType = args is UserType ? args : UserType.resident;

              switch (userType) {
                case UserType.resident:
                  return MaterialPageRoute(
                      builder: (_) => const ResidentProfileScreen());
                case UserType.manager:
                  return MaterialPageRoute(
                      builder: (_) => const ManagerProfileScreen());
                case UserType.serviceProvider:
                  return MaterialPageRoute(
                      builder: (_) => const CompanyProfileScreen());
              }
            }
            return MaterialPageRoute(builder: (_) => const AccountTypePage());
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
        userType: UserType.serviceProvider,
        // Or other appropriate default
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
    );
  }
}
