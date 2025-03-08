import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/features/chat/chat_list_page.dart';
import 'package:we_neighbour/features/maintenance/maintenance_screen.dart';
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
import 'package:we_neighbour/providers/chat_provider.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'package:we_neighbour/screens/manager_maintenance_screen.dart';
import 'package:we_neighbour/screens/pending_approval_page.dart';
import 'package:we_neighbour/screens/pending_tasks_screen.dart';
import 'package:we_neighbour/screens/reports_screen.dart';
import 'package:we_neighbour/screens/residents_requests_screen.dart';
import 'package:we_neighbour/settings/settings_screen.dart';
import 'package:we_neighbour/splashScreen/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserType { resident, manager, serviceProvider }

const String baseUrl = 'http://172.20.10.3:3000';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: isDarkMode)),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: false)),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
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
  String? _token;
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
        final userStatus = prefs.getString('userStatus')?.toLowerCase(); // Check status

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
          _token = token;
          _isLoading = false;
        });

        // If resident and pending, redirect to pending approval
        if (userType == UserType.resident && userStatus == 'pending') {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/pending-approval');
          }
        }
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

  Future<void> _syncFirebaseWithJwt(String jwtToken) async {
    try {
      // Placeholder for syncing Firebase with JWT (requires backend custom token)
      const customToken = 'your-custom-token-from-backend';
      await FirebaseAuth.instance.signInWithCustomToken(customToken);
    } catch (e) {
      print('Error syncing Firebase with JWT: $e');
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
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/account-type': (context) => const AccountTypePage(),
            '/resident-signup': (context) => const ResidentSignUpPage(),
            '/manager-signup': (context) => const ManagerSignUpPage(),
            '/service-provider-signup': (context) => const ServiceProviderSignUpPage(),
            '/provider-home': (context) => const ProviderHomePage(),
            '/provider-profile': (context) => const CompanyProfileScreen(),
            '/chat': (context) => const ChatListPage(),
            '/pending-approval': (context) => const PendingApprovalPage(),
            '/resource': (context) => const ResourceSharingPage(),
            '/resident-req': (context) => const ResidentsRequestsScreen(),
            '/pending-task': (context) => const PendingTasksScreen(),
            '/reports': (context) => const ReportsScreen(),
            '/login': (context) => const LoginPage(),
            '/settings': (context) => const SettingsScreen(),
            '/maintenance': (context) => _token != null
                ? MaintenanceScreen(authToken: _token!, isManager: _userType == UserType.manager)
                : const LoginPage(),
            '/manager-maintenance': (context) => _token != null
                ? ManagerMaintenanceScreen(authToken: _token!)
                : const LoginPage(),
            '/home': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final userType = args is UserType ? args : _userType;
              return userType == UserType.serviceProvider
                  ? ServicesPage(userType: userType)
                  : HomeScreen(userType: userType);
            },
            '/service': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final userType = args is UserType ? args : _userType;
              return ServicesPage(userType: userType);
            },
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/profile') {
              final args = settings.arguments;
              final userType = args is UserType ? args : _userType;
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