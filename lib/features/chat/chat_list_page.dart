import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/models/chat.dart' as chat_model;
import 'package:we_neighbour/providers/chat_provider.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'chat_screen.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  @override
  void initState() {
    super.initState();
    _syncUserData();
  }

  Future<void> _syncUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('firebaseUid') ?? prefs.getString('userId') ?? '';
    final apartmentName = prefs.getString('userApartment') ?? 'Negombo-Dreams';
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
            onPressed: () => Navigator.pushNamed(context, '/resource'),
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
            child: _buildChatList(context, false, isDarkMode, chatProvider),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Groups',
              style: AppTextStyles.getSubtitleStyle.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: _buildChatList(context, true, isDarkMode, chatProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context, isDarkMode, chatProvider),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, bool isGroup, bool isDarkMode, ChatProvider chatProvider) {
    return StreamBuilder<List<chat_model.Chat>>(
      stream: isGroup
          ? Stream.fromFuture(Future.value(chatProvider.getGroups()))
          : Stream.fromFuture(Future.value(chatProvider.getChats())),
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
              'No ${isGroup ? "groups" : "chats"} available.',
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
            ),
          );
        }
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return FutureBuilder<String?>(
              future: _getChatTitle(chat, chatProvider, isGroup),
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
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/chat-screen',
                    arguments: {
                      'chatId': chat.id,
                      'isGroup': chat.isGroup,
                      'resourceId': chat.resourceId,
                    },
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

  Future<String?> _getChatTitle(chat_model.Chat chat, ChatProvider chatProvider, bool isGroup) async {
    if (isGroup && chat.groupName != null) {
      return chat.groupName;
    } else if (!isGroup && chat.participants.length == 2) {
      final currentUserId = chatProvider.currentUserId;
      if (currentUserId == null || chatProvider.currentApartmentName == null) return 'Unknown User';

      final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);
      print('Fetching user name for user ID: $otherUserId in apartment: ${chatProvider.currentApartmentName}');
      try {
        final otherUserDoc = await FirebaseFirestore.instance
            .collection('home')
            .doc('apartment')
            .collection('apartments')
            .doc(chatProvider.currentApartmentName)
            .collection('users')
            .doc(otherUserId)
            .get();
        final userName = otherUserDoc.data()?['name'] ?? 'Unknown User';
        print('Fetched user name: $userName');
        return userName;
      } catch (e) {
        print('Error fetching user name: $e');
        return 'Unknown User';
      }
    }
    return 'Unknown Chat';
  }

  void _showCreateGroupDialog(BuildContext context, bool isDarkMode, ChatProvider chatProvider) async {
    final TextEditingController nameController = TextEditingController();
    final List<String> selectedMembers = [];

    final currentUserId = chatProvider.currentUserId;
    final currentApartmentName = chatProvider.currentApartmentName;
    if (currentUserId == null || currentApartmentName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User or apartment not authenticated')),
      );
      return;
    }

    try {
      print('Fetching users for group creation in apartment: $currentApartmentName');
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('home')
          .doc('apartment')
          .collection('apartments')
          .doc(currentApartmentName)
          .collection('users')
          .where('userId', isNotEqualTo: currentUserId)
          .get();

      final List<Map<String, dynamic>> apartmentUsers = usersSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] as String?,
                'userId': doc.data()['userId'] as String?,
              })
          .where((user) => user['name'] != null && user['userId'] != null)
          .toList();

      if (apartmentUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other users found in your apartment')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Create New Group',
              style: AppTextStyles.getGreetingStyle(isDarkMode),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      labelStyle: AppTextStyles.getBodyTextStyle(isDarkMode),
                    ),
                    style: AppTextStyles.getBodyTextStyle(isDarkMode),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add Members',
                    style: AppTextStyles.getBodyTextStyle(isDarkMode),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: apartmentUsers.length,
                      itemBuilder: (context, index) {
                        final user = apartmentUsers[index];
                        final isSelected = selectedMembers.contains(user['userId']);
                        return CheckboxListTile(
                          title: Text(
                            user['name'] ?? 'Unknown User',
                            style: AppTextStyles.getBodyTextStyle(isDarkMode),
                          ),
                          subtitle: Text(
                            user['userId'] ?? '',
                            style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(fontSize: 12),
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedMembers.add(user['userId'] as String);
                              } else {
                                selectedMembers.remove(user['userId'] as String);
                              }
                            });
                          },
                          activeColor: AppColors.primary,
                          checkColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty && selectedMembers.isNotEmpty) {
                    try {
                      await chatProvider.createGroup(nameController.text, selectedMembers);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Group "${nameController.text}" created successfully')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating group: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a group name and select at least one member')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Create Group',
                  style: AppTextStyles.getButtonTextStyle(isDarkMode).copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print('Error fetching users for group creation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching users: $e')),
      );
    }
  }
}