// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:we_neighbour/splashscreen/splash_screen.dart';

// void main() {
//   testWidgets('SplashScreen renders correctly', (WidgetTester tester) async {
//     // Build the SplashScreen widget
//     await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

//     // Verify that the logo is displayed
//     expect(find.byType(Image), findsOneWidget);

//     // Verify that the loading indicator is displayed
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);

//     // Verify that the app name is displayed
//     expect(find.text("We Neighbour"), findsOneWidget);

//     // Verify that the version number is displayed
//     expect(find.text("Version 1.0.0"), findsOneWidget);
//   });

//   testWidgets('SplashScreen animations run correctly', (WidgetTester tester) async {
//     // Build the SplashScreen widget
//     await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

//     // Initial state: Check that elements are present before animation progresses
//     expect(find.byType(Image), findsOneWidget);
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);

//     // Advance time by 1 second to simulate animation progress
//     await tester.pump(const Duration(milliseconds: 1000));

//     // Verify that UI elements are still present (or check for animated changes)
//     expect(find.byType(Image), findsOneWidget); // Adjust based on animation effect
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);

//     // Finish the animation (pumpAndSettle waits for all animations to complete)
//     await tester.pumpAndSettle();

//     // Verify the final state (e.g., screen still shows or navigates away)
//     expect(find.byType(Image), findsOneWidget); // Adjust if animation hides elements
//   });
// }