import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // Set up a mock SharedPreferences instance
    SharedPreferences.setMockInitialValues({'isDarkMode': false});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isDarkMode: false));

    // Verify that the app initializes without errors
    expect(find.byType(MaterialApp), findsOneWidget);

    // You can add more specific tests here based on your app's initial state
    // For example, you might want to check if the login page is displayed:
    // expect(find.byType(LoginPage), findsOneWidget);
  });

  // You can add more test cases here to check other aspects of your app
  // For example:
  
  testWidgets('Dark mode toggle test', (WidgetTester tester) async {
    // Set up a mock SharedPreferences instance
    SharedPreferences.setMockInitialValues({'isDarkMode': false});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isDarkMode: false));

    // Navigate to the settings screen (you might need to adjust this based on your navigation setup)
    // await tester.tap(find.byIcon(Icons.settings));
    // await tester.pumpAndSettle();

    // Find the dark mode switch
    final darkModeSwitch = find.byType(Switch);

    // Verify that the switch exists and is initially off
    expect(darkModeSwitch, findsOneWidget);
    expect(tester.widget<Switch>(darkModeSwitch).value, false);

    // Tap the switch to toggle dark mode
    await tester.tap(darkModeSwitch);
    await tester.pumpAndSettle();

    // Verify that the switch is now on
    expect(tester.widget<Switch>(darkModeSwitch).value, true);

    // You can add more assertions here to check if the app's theme has actually changed
  });
}

