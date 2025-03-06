import 'package:flutter/material.dart';
import '../models/user.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Mock user list (replace with data from your friend's MongoDB backend)
  final List<AppUser> users = const [
    AppUser(id: 'user1', email: 'user1@example.com'),
    AppUser(id: 'user2', email: 'user2@example.com'),
    AppUser(id: 'user3', email: 'user3@example.com'),
  ];

  @override
  Widget build(BuildContext context) {
    // Mock current user (replace with authenticated user ID from MongoDB)
    const currentUser = AppUser(id: 'user1', email: 'user1@example.com');

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