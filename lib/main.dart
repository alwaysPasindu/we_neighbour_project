import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'We Neighbour',
      theme: ThemeData(
        primaryColor: Colors.blue[700],
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
      
    );
  }
}
