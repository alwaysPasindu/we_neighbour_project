// import 'package:flutter/material.dart';
// import '../models/user.dart';
// import 'chat_screen.dart';

import 'package:flutter/material.dart';
import 'package:we_neighbour_project/models/app_user.dart'; // Adjust import path

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // List of users with const constructor
  static const List<AppUser> users = [
    AppUser(id: '67be1e8c5b07e787351b78e7', email: 'pasindu2002@gmail.com'),
    AppUser(id: '67c2f203312ebbd0051043d0', email: 'chamu@gmail.com'),
    AppUser(id: '67c788ed1d5c2bb7db76d908', email: 'weneighbourresident@gmail.com'),
  ];

  static const currentUser = AppUser(id: '67be1e8c5b07e787351b78e7', email: 'pasindu2002@gmail.com');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to WeNeighbour!'),
            const SizedBox(height: 20),
            Text('Current User: ${currentUser.email}'),
          ],
        ),
      ),
    );
  }
}