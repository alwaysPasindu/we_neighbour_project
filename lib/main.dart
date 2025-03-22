import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/constants/colors.dart';
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
import 'package:http/http.dart' as http;
import 'dart:convert';

enum UserType { resident, manager, serviceProvider }

const String baseUrl = 'https://we-neighbour-app-9modf.ondigitalocean.app';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => ThemeProvider(isDarkMode: isDarkMode)),
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
          ChangeNotifierProvider(
              create: (_) => ThemeProvider(isDarkMode: false)),
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

  get prefs => null;

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
        final userRole =
            prefs.getString('userRole')?.toLowerCase() ?? 'resident';
        final userStatus = prefs.getString('userStatus')?.toLowerCase();

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

        // Sync Firebase with JWT (optional, uncomment if needed)
        // await _syncFirebaseWithJwt(token);

        setState(() {
          _isLoggedIn = true;
          _userType = userType;
          _token = token;
          _isLoading = false;
        });

        // Redirect to appropriate screen based on user status
        if (mounted) {
          if (userType == UserType.resident && userStatus == 'pending') {
            Navigator.pushReplacementNamed(context, '/pending-approval');
          } else if (userType == UserType.resident ||
              userType == UserType.manager) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (userType == UserType.serviceProvider) {
            Navigator.pushReplacementNamed(context, '/provider-home');
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
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/firebase-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'jwtToken': jwtToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final customToken = data['firebaseToken'];
        await FirebaseAuth.instance.signInWithCustomToken(customToken);
        print('Firebase synced with JWT successfully');
      } else {
        print(
            'Failed to get Firebase token: ${response.statusCode} - ${response.body}');
      }
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
          initialRoute: '/splash', // Always start with splash screen
          routes: {
            '/splash': (context) => SplashScreen(
                  onFinish: () {
                    if (_isLoggedIn) {
                      if (_userType == UserType.resident &&
                          prefs.getString('userStatus')?.toLowerCase() ==
                              'pending') {
                        Navigator.pushReplacementNamed(
                            context, '/pending-approval');
                      } else if (_userType == UserType.serviceProvider) {
                        Navigator.pushReplacementNamed(
                            context, '/provider-home');
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                ),
            '/login': (context) => const LoginPage(),
            '/account-type': (context) => const AccountTypePage(),
            '/resident-signup': (context) => const ResidentSignUpPage(),
            '/manager-signup': (context) => const ManagerSignUpPage(),
            '/service-provider-signup': (context) =>
                const ServiceProviderSignUpPage(),
            '/home': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final userType = args is UserType ? args : _userType;
              return HomeScreen(userType: userType);
            },
            '/provider-home': (context) => const ProviderHomePage(),
            '/service': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              final userType = args is UserType ? args : _userType;
              return ServicesPage(userType: userType);
            },
            '/maintenance': (context) => _token != null
                ? MaintenanceScreen(
                    authToken: _token!,
                    isManager: _userType == UserType.manager)
                : const LoginPage(),
            '/manager-maintenance': (context) => _token != null
                ? ManagerMaintenanceScreen(authToken: _token!)
                : const LoginPage(),
            '/resource': (context) => const ResourceSharingPage(),
            '/resident-req': (context) => const ResidentsRequestScreen(),
            '/pending-task': (context) => const PendingTasksScreen(),
            '/reports': (context) => const ReportsScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/pending-approval': (context) => const PendingApprovalPage(),
            '/provider-profile': (context) => const CompanyProfileScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/profile') {
              final args = settings.arguments;
              final userType = args is UserType ? args : _userType;
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
            return null;
          },
        );
      },
    );
  }
}
