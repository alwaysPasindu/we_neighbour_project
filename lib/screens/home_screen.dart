import 'package:flutter/material.dart';
import 'chat_screen.dart'; // Import the ChatScreen

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to the Home Screen!'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the ChatScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatId: 'default_chat_id', // Replace with your chat ID logic
                      userId: 'current_user_id', // Replace with your user ID logic
                    ),
                  ),
                );
              },
              child: Text('Go to Chat'),
            ),
          ],
        ),
      ),
    );
  }
}