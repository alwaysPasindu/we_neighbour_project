import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/features/chat/chat_list_page.dart';
import 'package:we_neighbour/features/resource_share/resource_sharing_page.dart';
import 'package:we_neighbour/features/services/service_page.dart';
import 'package:we_neighbour/home/home_screen.dart';
import 'package:we_neighbour/home/provider_home_page.dart';
import 'package:we_neighbour/login&signup/account_type_page.dart';
import 'package:we_neighbour/login&signup/login_page.dart';
import 'package:we_neighbour/login&signup/manager_signup_page.dart';
import 'package:we_neighbour/login&signup/provider_signup_page.dart';
import 'package:we_neighbour/login&signup/resident_signup_page.dart';
import 'package:we_neighbour/profiles/manager_profile_screen.dart';
import 'package:we_neighbour/profiles/provider_profile_screen.dart';
import 'package:we_neighbour/profiles/resident_profile_screen.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'package:we_neighbour/settings/settings_screen.dart';

enum UserType { resident, manager, serviceProvider }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(isDarkMode: isDarkMode),
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(isDarkMode: false),
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  UserType _userType = UserType.resident;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final userRole = prefs.getString('userRole')?.toLowerCase() ?? 'resident';
        UserType userType;

        switch (userRole) {
          case 'manager':
            userType = UserType.manager;
            break;
          case 'serviceprovider':
          case 'service_provider':
            userType = UserType.serviceProvider;
            break;
          case 'resident':
          default:
            userType = UserType.resident;
        }

        setState(() {
          _isLoggedIn = true;
          _userType = userType;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking login status: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'We Neighbour',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              secondary: Colors.blue,
            ),
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            visualDensity: VisualDensity.adaptivePlatformDensity,
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
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: _isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _isLoggedIn
                  ? _userType == UserType.serviceProvider
                      ? ServicesPage(userType: _userType)
                      : HomeScreen(userType: _userType)
                  : const LoginPage(),
          routes: {
            '/account-type': (context) => const AccountTypePage(),
            '/resident-signup': (context) => const ResidentSignUpPage(),
            '/manager-signup': (context) => const ManagerSignUpPage(),
            '/service-provider-signup': (context) => const ServiceProviderSignUpPage(),
            '/provider-home': (context) => const ProviderHomePage(),
            '/provider-profile': (context) => const CompanyProfileScreen(),
            '/chat': (context) => const ChatListPage(),
            '/resource': (context) => const ResourceSharingPage(),
            '/login': (context) => const LoginPage(),
            '/settings': (context) => const SettingsScreen(),
            '/home': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final userType = args is UserType ? args : UserType.resident;
              return userType == UserType.serviceProvider ? ServicesPage(userType: userType) : HomeScreen(userType: userType);
            },
            '/service': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final userType = args is UserType ? args : UserType.resident;
              return ServicesPage(userType: userType);
            },
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
        );
      },
    );
  }
}