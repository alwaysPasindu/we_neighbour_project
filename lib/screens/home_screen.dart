import 'package:flutter/material.dart';
import '../models/user.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Mock user list (replace with data from your friend's MongoDB backend)
  final List<AppUser> users = const [
    AppUser(id: '67be1e8c5b07e787351b78e7', email: 'pasindu2002@gmail.com'),
    AppUser(id: '67c2f203312ebbd0051043d0', email: 'chamu@gmail.com'),
    AppUser(id: '67c788ed1d5c2bb7db76d908', email: 'weneighbourresident@gmail.com'),
  ];

  @override
  Widget build(BuildContext context) {
    // Mock current user (replace with authenticated user ID from MongoDB)
    const currentUser = AppUser(id: '67be1e8c5b07e787351b78e7', email: 'pasindu2002@gmail.com');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFF075E54), // WhatsApp green
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          if (user.id == currentUser.id) return const SizedBox.shrink(); // Skip current user
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(user.email),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    currentUser: currentUser,
                    receiver: user,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}