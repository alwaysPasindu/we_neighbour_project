import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/models/chat.dart';
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode; // Correctly typed as bool
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chats',
          style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'One-on-One Chats',
              style: AppTextStyles.getSubtitleStyle .copyWith(
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
        child: Icon(Icons.group_add, color: Colors.white),
      ),
    );
  }

  Widget _buildChatList(BuildContext context, bool isGroup, bool isDarkMode, ChatProvider chatProvider) {
    return StreamBuilder<List<Chat>>(
      stream: isGroup ? chatProvider.getGroups() : chatProvider.getChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white as Color)); // Explicit cast to Color
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
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return FutureBuilder<String?>(
              future: _getChatTitle(chat, chatProvider, isGroup),
              builder: (context, titleSnapshot) {
                if (titleSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('Loading...', 
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
                    style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen(chatId: chat.id, isGroup: chat.isGroup)),
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

  Future<String?> _getChatTitle(Chat chat, ChatProvider chatProvider, bool isGroup) async {
    if (isGroup && chat.name != null) {
      return chat.name; // Use group name for groups
    } else if (!isGroup && chat.participants.length == 2) {
      // For one-on-one chats, get the other participant's name, ensuring same apartment
      final currentUserId = chatProvider.currentUserId;
      if (currentUserId == null) return 'Unknown User';
      
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      final currentApartmentCode = currentUserDoc.data()?['apartmentCode'] as String?;

      final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);
      final otherUserDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
      final otherApartmentCode = otherUserDoc.data()?['apartmentCode'] as String?;

      if (currentApartmentCode != null && otherApartmentCode != null && currentApartmentCode == otherApartmentCode) {
        return otherUserDoc.data()?['name'] ?? 'Unknown User';
      }
      return null; // Return null if not from the same apartment
    }
    return 'Unknown Chat';
  }

  void _showCreateGroupDialog(BuildContext context, bool isDarkMode, ChatProvider chatProvider) async {
    final TextEditingController nameController = TextEditingController();
    final List<String> selectedMembers = [];
    String? currentApartmentCode;

    // Fetch current user's apartment code with enhanced error handling
    final currentUserId = chatProvider.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not authenticated. Please log in again.')),
      );
      print('Error: currentUserId is null in _showCreateGroupDialog');
      return;
    }

    try {
      final currentUserDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
      if (!currentUserDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User data not found in Firestore. Please contact support.')),
        );
        print('Error: User document does not exist for userId: $currentUserId');
        return;
      }

      currentApartmentCode = currentUserDoc.data()?['apartmentCode'] as String?;
      if (currentApartmentCode == null || currentApartmentCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to determine your apartment. Please ensure your profile has an apartment code.')),
        );
        print('Error: apartmentCode is null or empty for userId: $currentUserId. Data: ${currentUserDoc.data()}');
        return;
      }

      print('Successfully fetched apartmentCode: $currentApartmentCode for userId: $currentUserId');

      // Fetch users from the same apartment
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('apartmentCode', isEqualTo: currentApartmentCode)
          .where('id', isNotEqualTo: currentUserId) // Exclude current user
          .get();

      final List<Map<String, dynamic>> apartmentUsers = usersSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc.data()['name'] as String?,
              })
          .where((user) => user['name'] != null) // Filter out users without names
          .toList();

      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              'Create Group',
              style: AppTextStyles.getGreetingStyle(isDarkMode),
            ),
            content: Column(
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
                  'Add Members from Your Apartment',
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: apartmentUsers.length,
                    itemBuilder: (context, index) {
                      final user = apartmentUsers[index];
                      final isSelected = selectedMembers.contains(user['id']);
                      return CheckboxListTile(
                        title: Text(
                          user['name'] ?? 'Unknown User',
                          style: AppTextStyles.getBodyTextStyle(isDarkMode),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedMembers.add(user['id'] as String);
                            } else {
                              selectedMembers.remove(user['id'] as String);
                            }
                          });
                        },
                        tileColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
                        activeColor: AppColors.primary,
                        checkColor: Colors.white,
                      );
                    },
                  ),
                ),
              ],
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
                    await chatProvider.createGroup(nameController.text, selectedMembers);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a group name and select at least one member.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Create',
                  style: AppTextStyles.getButtonTextStyle(isDarkMode).copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching apartment data: $e')),
      );
      print('Error in _showCreateGroupDialog: $e');
    }
  }
}