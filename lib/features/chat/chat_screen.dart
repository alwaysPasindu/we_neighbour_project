import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/models/message.dart' as message_model;
import 'package:we_neighbour/providers/chat_provider.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'package:we_neighbour/models/chat.dart' as message_model;

class ChatScreen extends StatefulWidget {
  final String chatId;
  final bool isGroup;

  const ChatScreen({super.key, required this.chatId, required this.isGroup});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _replyTo; // Tracks the resource or message being replied to
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to the bottom when the chat loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode; // Correctly typed as bool
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isGroup ? 'Group Chat' : 'Chat',
          style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<message_model.Message>>(
              stream: chatProvider.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: AppTextStyles.getBodyTextStyle(isDarkMode),
                    ),
                  );
                }
                final messages = snapshot.data ?? [];
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Newest messages at the bottom
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessage(message, chatProvider.currentUserId!, isDarkMode);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(isDarkMode, chatProvider),
        ],
      ),
    );
  }

  Widget _buildMessage(message_model.Message message, String currentUserId, bool isDarkMode) {
    final isMe = message.senderId == currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isReply && message.replyTo != null)
              GestureDetector(
                onTap: () {
                  // Optionally navigate to the resource or show details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Replying to Resource ID: ${message.replyTo}',
                        style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(color: isDarkMode ? Colors.white70 : Colors.grey[600]),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDarkMode ? Colors.grey[600]! : Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    'Replying to Resource: ${message.replyTo}',
                    style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            Text(
              message.content,
              style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                color: isMe ? Colors.white : (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
            Text(
              message.timestamp.toString().split('.')[0], // Format timestamp
              style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                fontSize: 10,
                color: isMe ? Colors.white70 : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDarkMode, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  // Updated to ensure non-nullable Color
                  borderSide: BorderSide(color: isDarkMode ? (Colors.grey[700]! as Color) : (Colors.grey[300]! as Color)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  // Updated to ensure non-nullable Color
                  borderSide: BorderSide(color: isDarkMode ? (Colors.grey[700]! as Color) : (Colors.grey[300]! as Color)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  // Updated to ensure non-nullable Color (assuming AppColors.primary is Color, not Color?)
                  borderSide: BorderSide(color: AppColors.primary as Color),
                ),
              ),
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: AppColors.primary,
            ),
            onPressed: () async {
              if (_messageController.text.isNotEmpty) {
                await chatProvider.sendMessage(
                  widget.chatId,
                  _messageController.text,
                  replyTo: _replyTo,
                );
                _messageController.clear();
                _replyTo = null; // Clear reply after sending
                _scrollToBottom(); // Scroll to the newest message
              }
            },
          ),
          if (_replyTo != null)
            IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  _replyTo = null; // Cancel reply
                });
              },
            ),
        ],
      ),
    );
  }

  void _showReplyDialog(String resourceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Reply to Resource',
          style: AppTextStyles.getGreetingStyle(Provider.of<ThemeProvider>(context).isDarkMode),
        ),
        content: Text(
          'Send a message replying to Resource ID: $resourceId',
          style: AppTextStyles.getBodyTextStyle(Provider.of<ThemeProvider>(context).isDarkMode),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.getBodyTextStyle(Provider.of<ThemeProvider>(context).isDarkMode),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _replyTo = resourceId;
              });
              Navigator.pop(context);
              _scrollToBottom(); // Ensure the input is visible
            },
            child: Text(
              'Reply',
              style: AppTextStyles.getButtonTextStyle(Provider.of<ThemeProvider>(context).isDarkMode).copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}