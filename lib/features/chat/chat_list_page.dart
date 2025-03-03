import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/providers/theme_provider.dart';

class ChatModel {
  final String id;
  final String name;
  final String lastMessage;
  final String avatar;
  final DateTime timestamp;
  final bool isRead;
  final String messageType; // 'text', 'photo', 'voice'

  ChatModel({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatar,
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
  });
}

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final List<ChatModel> chats = [
      ChatModel(
        id: '1',
        name: 'Local Legends',
        lastMessage: 'Yes, 2pm is awesome',
        avatar: 'assets/avatars/local_legends.png',
        timestamp: DateTime(2024, 11, 19),
        isRead: true,
        messageType: 'text',
      ),
      ChatModel(
        id: '2',
        name: 'Around the corner',
        lastMessage: 'What kind of strategy is better?',
        avatar: 'assets/avatars/troll_face.png',
        timestamp: DateTime(2024, 11, 16),
        isRead: true,
        messageType: 'text',
      ),
      ChatModel(
        id: '3',
        name: 'Floor 6',
        lastMessage: '0:14',
        avatar: 'assets/avatars/floor6.png',
        timestamp: DateTime(2024, 11, 15),
        isRead: false,
        messageType: 'voice',
      ),
      ChatModel(
        id: '4',
        name: 'Our happy place',
        lastMessage: 'Bro, I have a good idea!',
        avatar: 'assets/avatars/happy_place.png',
        timestamp: DateTime(2024, 10, 30),
        isRead: true,
        messageType: 'text',
      ),
      ChatModel(
        id: '5',
        name: 'Lend a hand',
        lastMessage: 'Photo',
        avatar: 'assets/avatars/lend_hand.png',
        timestamp: DateTime(2024, 10, 28),
        isRead: false,
        messageType: 'photo',
      ),
      ChatModel(
        id: '6',
        name: 'The social circle',
        lastMessage: 'Welcome, to make design process faster, look at Pixsellz',
        avatar: 'assets/avatars/social_circle.png',
        timestamp: DateTime(2024, 8, 20),
        isRead: true,
        messageType: 'text',
      ),
      ChatModel(
        id: '7',
        name: 'Chatter box',
        lastMessage: 'Ok, have a good trip!',
        avatar: 'assets/avatars/chatter_box.png',
        timestamp: DateTime(2024, 7, 29),
        isRead: true,
        messageType: 'text',
      ),
    ];

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with fixed height
            Container(
              height: 80, // Fixed height for the header
              color: const Color(0xFF042347),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25, // Slightly smaller radius
                    backgroundImage: AssetImage('assets/avatars/profile.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'John Doe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Chats',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16, // Slightly smaller font
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // New Group Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Handle new group creation
                },
                child: Text(
                  'New Group',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Chat List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero, // Remove default padding
                itemCount: chats.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                ),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 24, // Slightly smaller radius
                      backgroundColor: Colors.grey[300],
                      backgroundImage: AssetImage(chat.avatar),
                    ),
                    title: Text(
                      chat.name,
                      style: TextStyle(
                        fontSize: 16, // Slightly smaller font
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        if (chat.isRead)
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.done_all,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ),
                        if (chat.messageType == 'voice')
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.mic,
                              size: 14,
                              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        if (chat.messageType == 'photo')
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Icon(
                              Icons.photo_camera,
                              size: 14,
                              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            chat.lastMessage,
                            style: TextStyle(
                              fontSize: 14, // Slightly smaller font
                              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDate(chat.timestamp),
                          style: TextStyle(
                            color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.chevron_right,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to chat detail
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}/${date.year.toString().substring(2)}';
    }
  }
}