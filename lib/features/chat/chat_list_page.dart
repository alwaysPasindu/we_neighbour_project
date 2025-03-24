import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/models/chat.dart';
import 'package:we_neighbour/providers/chat_provider.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'package:logger/logger.dart';
import 'chat_screen.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key, required UserType userType});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _syncUserData();
  }

  Future<void> _syncUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    final apartmentName = prefs.getString('userApartment') ?? 'UnknownApartment';
    
    // Check if the widget is still mounted before using context
    if (!mounted) return;
    
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (userId.isNotEmpty && chatProvider.currentUserId != userId) {
      chatProvider.setUser(userId, apartmentName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final chatProvider = Provider.of<ChatProvider>(context);

    if (chatProvider.currentUserId == null || chatProvider.currentUserId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Chats',
            style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: Text('Please log in to view chats.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Navigator.pushNamed(context, '/resources'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'One-on-One Chats',
              style: AppTextStyles.getSubtitleStyle.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: _buildChatList(context, isDarkMode, chatProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(BuildContext context, bool isDarkMode, ChatProvider chatProvider) {
    return StreamBuilder<List<Chat>>(
      stream: chatProvider.getChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
            ),
          );
        }
        final chats = snapshot.data ?? [];
        if (chats.isEmpty) {
          return Center(
            child: Text(
              'No chats available.',
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
            ),
          );
        }
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return FutureBuilder<String?>(
              future: _getChatTitle(chat, chatProvider),
              builder: (context, titleSnapshot) {
                if (titleSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text(
                      'Loading...',
                      style: AppTextStyles.getSubtitleStyle.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    tileColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  );
                }
                final title = titleSnapshot.data ?? 'Unknown Chat';
                return ListTile(
                  title: Text(
                    title,
                    style: AppTextStyles.getSubtitleStyle.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    chat.lastMessage ?? 'No messages yet',
                    style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatId: chat.id, isGroup: false),
                    ),
                  ),
                  tileColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<String?> _getChatTitle(Chat chat, ChatProvider chatProvider) async {
    if (chat.participants.length == 2) {
      final currentUserId = chatProvider.currentUserId;
      if (currentUserId == null || chatProvider.currentApartmentName == null) return 'Unknown User';

      final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);
      try {
        final otherUserDoc = await FirebaseFirestore.instance
            .collection('apartments')
            .doc(chatProvider.currentApartmentName)
            .collection('users')
            .doc(otherUserId)
            .get();
        return otherUserDoc.data()?['name'] ?? 'Unknown User';
      } catch (e) {
        logger.d('Error fetching user name: $e');
        return 'Unknown User';
      }
    }
    return 'Unknown Chat';
  }
}