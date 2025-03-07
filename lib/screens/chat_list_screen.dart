import 'package:flutter/material.dart';
import 'package:WE_NEIGHBOUR_PROJECT/screens/chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final String userId;
  final List<Map<String, String>> chatList = [
    {'name': 'Alice', 'lastMessage': 'Hey, how are you?', 'time': '10:30 AM'},
    {'name': 'Bob', 'lastMessage': 'Let’s meet up!', 'time': 'Yesterday'},
    {'name': 'Charlie', 'lastMessage': 'See you soon!', 'time': 'Monday'},
  ];

  ChatListScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          final chat = chatList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey,
              child: Text(chat['name']![0], style: TextStyle(color: Colors.white)),
            ),
            title: Text(chat['name']!),
            subtitle: Text(chat['lastMessage']!),
            trailing: Text(chat['time']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chatId: 'chat_${index + 1}',
                    userName: chat['name']!,
                    userId: userId,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Start a new chat (feature coming soon)")),
          );
        },
        child: Icon(Icons.message),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}