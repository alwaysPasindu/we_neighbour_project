import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/models/message.dart';
import 'package:we_neighbour/providers/chat_provider.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final bool isGroup;

  const ChatScreen({super.key, required this.chatId, required this.isGroup});

  @override
  State<ChatScreen> createState() => _ChatScreenState(); // Made public by using State<ChatScreen>
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _canReply = true; // Default to true
  bool _isLoading = true;
  final logger = Logger(); // Initialize Logger instance

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    logger.d('Initializing chat for chatId: ${widget.chatId}');
    await _checkReplyPermission();
    logger.d('After permission check - _canReply: $_canReply, _isLoading: $_isLoading');
    _scrollToBottom();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      logger.d('Set _isLoading to false');
    }
  }

  Future<void> _checkReplyPermission() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    try {
      final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
      if (!chatDoc.exists) {
        logger.d('Chat document does not exist for chatId: ${widget.chatId}');
        _canReply = true; // Default to true if chat doesn't exist yet
        return;
      }
      final isResourceChat = chatDoc.data()?['isResourceChat'] ?? false;
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      logger.d('isResourceChat: $isResourceChat, participants: $participants, currentUserId: ${chatProvider.currentUserId}');

      // Allow both sender and receiver to reply in all chats (resource or not)
      _canReply = true;
      logger.d('Setting _canReply to true for all users');
    } catch (e) {
      logger.d('Error checking reply permission: $e');
      _canReply = true; // Default to true on error
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(ChatProvider chatProvider) async {
    if (_messageController.text.isEmpty) return;

    try {
      await chatProvider.sendMessage(widget.chatId, _messageController.text);
      if (!mounted) return; // Check if still mounted before proceeding
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return; // Check if still mounted before using context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  void _deleteMessage(ChatProvider chatProvider, String messageId, bool deleteForEveryone) async {
    try {
      await chatProvider.deleteMessage(widget.chatId, messageId, deleteForEveryone);
      if (!mounted) return; // Check if still mounted before proceeding
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return; // Check if still mounted before using context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: _getChatTitle(chatProvider),
          builder: (context, snapshot) {
            return Text(
              snapshot.data ?? 'Chat',
              style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(color: Colors.white),
            );
          },
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
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
                final messages = snapshot.data?.docs.map((doc) {
                  return Message.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                }).toList() ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message.senderId == chatProvider.currentUserId;
                    return Column(
                      crossAxisAlignment:
                          isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                          child: Text(
                            DateFormat('yyyy-MM-dd HH:mm:ss').format(message.timestamp.toDate()),
                            style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onLongPress: () {
                            if (isSender) {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Delete for Me'),
                                      onTap: () {
                                        _deleteMessage(chatProvider, message.id, false);
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete_forever),
                                      title: const Text('Delete for Everyone'),
                                      onTap: () {
                                        _deleteMessage(chatProvider, message.id, true);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: isSender ? AppColors.primary : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              message.content,
                              style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                                color: isSender ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else if (_canReply)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                        filled: true,
                        fillColor: isDarkMode ? AppColors.darkCardBackground : Colors.white,
                      ),
                      style: AppTextStyles.getBodyTextStyle(isDarkMode),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: AppColors.primary,
                    onPressed: () => _sendMessage(chatProvider),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<String> _getChatTitle(ChatProvider chatProvider) async {
    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
    final chatData = chatDoc.data();
    if (!widget.isGroup && chatData?['participants'] != null) {
      final participants = List<String>.from(chatData!['participants']);
      final otherUserId = participants.firstWhere((id) => id != chatProvider.currentUserId);
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('apartments')
            .doc(chatProvider.currentApartmentName)
            .collection('users')
            .doc(otherUserId)
            .get();
        return userDoc.data()?['name'] ?? 'Unknown User';
      } catch (e) {
        logger.d('Error fetching user name: $e');
        return 'Unknown User';
      }
    }
    return 'Chat';
  }
}