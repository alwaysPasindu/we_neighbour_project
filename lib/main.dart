import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp();
  }
}

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'My Apartment App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: AppColors.primary,
//         scaffoldBackgroundColor: AppColors.background,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }
