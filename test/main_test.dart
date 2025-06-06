// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:we_neighbour/home/home_screen.dart';
// import 'package:we_neighbour/main.dart';
// import 'package:we_neighbour/providers/theme_provider.dart';
// import 'package:we_neighbour/providers/chat_provider.dart';
// import 'package:we_neighbour/screens/pending_approval_page.dart';
// import 'package:we_neighbour/splashscreen/splash_screen.dart';

// // Generate mocks for Firebase and SharedPreferences
// // import 'main_test.mocks.dart';

// @GenerateMocks([FirebaseApp, SharedPreferences])
// void main() {
//   // Mock Firebase initialization
//   setUpAll(() async {
//     TestWidgetsFlutterBinding.ensureInitialized();
//     final mockFirebaseApp = MockFirebaseApp();
//     when(Firebase.initializeApp()).thenAnswer((_) async => mockFirebaseApp);
//   });

//   group('MyApp Tests', () {
//     testWidgets('MyApp renders SplashScreen when not logged in', (WidgetTester tester) async {
//       // Mock SharedPreferences with no token (not logged in)
//       final mockPrefs = MockSharedPreferences();
//       when(mockPrefs.getString('token')).thenReturn(null);
//       when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
//       SharedPreferences.setMockInitialValues({});

//       // Pump the app with providers
//       await tester.pumpWidget(
//         MultiProvider(
//           providers: [
//             ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: false)),
//             ChangeNotifierProvider(create: (_) => ChatProvider()),
//           ],
//           child: const MyApp(),
//         ),
//       );

//       // Allow time for _checkLoginStatus to complete
//       await tester.pumpAndSettle();

//       // Verify that SplashScreen is displayed
//       expect(find.byType(SplashScreen), findsOneWidget);

//       // Verify SplashScreen UI elements (based on your earlier test)
//       expect(find.byType(Image), findsOneWidget); // Logo
//       expect(find.byType(CircularProgressIndicator), findsOneWidget); // Loading indicator
//       expect(find.text("We Neighbour"), findsOneWidget); // App name
//       expect(find.text("Version 1.0.0"), findsOneWidget); // Version
//     });

//     testWidgets('MyApp navigates to HomeScreen when logged in as resident', (WidgetTester tester) async {
//       // Mock SharedPreferences with a resident token
//       final mockPrefs = MockSharedPreferences();
//       when(mockPrefs.getString('token')).thenReturn('resident_token');
//       when(mockPrefs.getString('userRole')).thenReturn('resident');
//       when(mockPrefs.getString('userStatus')).thenReturn('approved');
//       when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
//       SharedPreferences.setMockInitialValues({
//         'token': 'resident_token',
//         'userRole': 'resident',
//         'userStatus': 'approved',
//         'isDarkMode': false,
//       });

//       // Pump the app with providers
//       await tester.pumpWidget(
//         MultiProvider(
//           providers: [
//             ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: false)),
//             ChangeNotifierProvider(create: (_) => ChatProvider()),
//           ],
//           child: const MyApp(),
//         ),
//       );

//       // Allow time for _checkLoginStatus to complete and navigation to occur
//       await tester.pumpAndSettle();

//       // Verify that HomeScreen is displayed for resident
//       expect(find.byType(HomeScreen), findsOneWidget);
//     });

//     testWidgets('MyApp shows PendingApprovalPage when resident is pending', (WidgetTester tester) async {
//       // Mock SharedPreferences with a pending resident
//       final mockPrefs = MockSharedPreferences();
//       when(mockPrefs.getString('token')).thenReturn('resident_token');
//       when(mockPrefs.getString('userRole')).thenReturn('resident');
//       when(mockPrefs.getString('userStatus')).thenReturn('pending');
//       when(mockPrefs.getBool('isDarkMode')).thenReturn(false);
//       SharedPreferences.setMockInitialValues({
//         'token': 'resident_token',
//         'userRole': 'resident',
//         'userStatus': 'pending',
//         'isDarkMode': false,
//       });

//       // Pump the app with providers
//       await tester.pumpWidget(
//         MultiProvider(
//           providers: [
//             ChangeNotifierProvider(create: (_) => ThemeProvider(isDarkMode: false)),
//             ChangeNotifierProvider(create: (_) => ChatProvider()),
//           ],
//           child: const MyApp(),
//         ),
//       );

//       // Allow time for _checkLoginStatus to complete and navigation to occur
//       await tester.pumpAndSettle();

//       // Verify that PendingApprovalPage is displayed
//       expect(find.byType(PendingApprovalPage), findsOneWidget);
//     });
//   });
// }

// // Mock classes (generated by Mockito)
// class MockFirebaseApp extends Mock implements FirebaseApp {}
// class MockSharedPreferences extends Mock implements SharedPreferences {}