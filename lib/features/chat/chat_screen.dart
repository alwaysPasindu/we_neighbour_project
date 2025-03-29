import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _canReply = true;
  bool _isLoading = true;
  final logger = Logger();
  late AnimationController _sendButtonController;
  bool _isComposing = false;

  // Cache for chat title and sender names
  String? _cachedChatTitle;
  String? _otherUserAvatar;
  final Map<String, String> _senderNameCache = {};

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _messageController.addListener(_handleTextChange);
    _initializeChat();
  }

  void _handleTextChange() {
    setState(() {
      _isComposing = _messageController.text.isNotEmpty;
    });
    if (_isComposing) {
      _sendButtonController.forward();
    } else {
      _sendButtonController.reverse();
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_handleTextChange);
    _messageController.dispose();
    _scrollController.dispose();
    _sendButtonController.dispose();
    super.dispose();
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
      final messageText = _messageController.text;
      _messageController.clear();
      setState(() {
        _isComposing = false;
      });
      _sendButtonController.reverse();

      await chatProvider.sendMessage(widget.chatId, messageText);
      if (!mounted) return;
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteMessage(ChatProvider chatProvider, String messageId, bool deleteForEveryone) async {
    try {
      await chatProvider.deleteMessage(widget.chatId, messageId, deleteForEveryone);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deleteForEveryone ? 'Message deleted for everyone' : 'Message deleted'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting message: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String> _getSenderName(String senderId, ChatProvider chatProvider) async {
    if (_senderNameCache.containsKey(senderId)) {
      return _senderNameCache[senderId]!;
    }

    try {
      String? apartmentName = chatProvider.currentApartmentName;
      if (apartmentName == null || apartmentName.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        apartmentName = prefs.getString('userApartment');
      }

      if (apartmentName != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('apartments')
            .doc(apartmentName)
            .collection('users')
            .doc(senderId)
            .get();

        if (userDoc.exists && userDoc.data()?['name'] != null) {
          final senderName = userDoc.data()!['name'] as String;
          _senderNameCache[senderId] = senderName;
          return senderName;
        }
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(senderId).get();
      if (userDoc.exists && userDoc.data()?['name'] != null) {
        final senderName = userDoc.data()!['name'] as String;
        _senderNameCache[senderId] = senderName;
        return senderName;
      }

      _senderNameCache[senderId] = 'Unknown User';
      return 'Unknown User';
    } catch (e) {
      logger.e('Error fetching sender name for $senderId: $e');
      _senderNameCache[senderId] = 'Unknown User';
      return 'Unknown User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: _getChatDetails(chatProvider),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.isGroup ? Icons.group : Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Loading...',
                        style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'Fetching details',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            final details = snapshot.data ?? {'name': 'Chat', 'avatar': null, 'status': null};
            final name = details['name'] as String;
            final avatar = details['avatar'] as String?;
            final status = details['status'] as String?;

            if (_cachedChatTitle == null) {
              _cachedChatTitle = name;
              _otherUserAvatar = avatar;
            }

            return Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: avatar != null && avatar.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            avatar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                widget.isGroup ? Icons.group : Icons.person,
                                color: Colors.white,
                              );
                            },
                          ),
                        )
                      : Icon(
                          widget.isGroup ? Icons.group : Icons.person,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        status ?? (widget.isGroup ? 'Group chat' : 'Private chat'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
          image: DecorationImage(
            image: AssetImage(isDarkMode ? 'assets/images/white.png' : 'assets/images/logo.jpeg'),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: Column(
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
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading messages',
                            style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            onPressed: () {
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = snapshot.data?.docs.map((doc) {
                    return Message.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                  }).toList() ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 64,
                            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No messages yet',
                            style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cachedChatTitle != null
                                ? 'Start a conversation with $_cachedChatTitle'
                                : 'Start the conversation by sending a message',
                            style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isSender = message.senderId == chatProvider.currentUserId;

                      final bool showDateHeader = index == 0 ||
                          !_isSameDay(messages[index - 1].timestamp.toDate(), message.timestamp.toDate());

                      return Column(
                        children: [
                          if (showDateHeader) _buildDateHeader(message.timestamp.toDate(), isDarkMode),
                          _buildMessageItem(message, isSender, isDarkMode, chatProvider),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 3,
                ),
              )
            else if (_canReply)
              _buildMessageComposer(isDarkMode, chatProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildDateHeader(DateTime date, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800]!.withOpacity(0.7) : Colors.grey[300]!.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _formatDateHeader(date),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Widget _buildMessageItem(Message message, bool isSender, bool isDarkMode, ChatProvider chatProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isSender)
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: _otherUserAvatar != null && _otherUserAvatar!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            _otherUserAvatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 16, color: Colors.white);
                            },
                          ),
                        )
                      : const Icon(Icons.person, size: 16, color: Colors.white),
                ),
              Flexible(
                child: GestureDetector(
                  onLongPress: () {
                    if (isSender) {
                      HapticFeedback.mediumImpact();
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.copy, color: AppColors.primary),
                              title: Text(
                                'Copy Message',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: message.content));
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Message copied to clipboard'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.orange),
                              title: Text(
                                'Delete for Me',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              onTap: () {
                                _deleteMessage(chatProvider, message.id, false);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete_forever, color: Colors.red),
                              title: Text(
                                'Delete for Everyone',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              onTap: () {
                                _deleteMessage(chatProvider, message.id, true);
                                Navigator.pop(context);
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    } else {
                      HapticFeedback.mediumImpact();
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.copy, color: AppColors.primary),
                              title: Text(
                                'Copy Message',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: message.content));
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Message copied to clipboard'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSender
                          ? AppColors.primary
                          : isDarkMode
                              ? Colors.grey[800]
                              : Colors.white,
                      borderRadius: BorderRadius.circular(18).copyWith(
                        bottomLeft: isSender ? Radius.circular(18) : Radius.circular(0),
                        bottomRight: isSender ? Radius.circular(0) : Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display sender's name inside the bubble
                        FutureBuilder<String>(
                          future: _getSenderName(message.senderId, chatProvider),
                          builder: (context, snapshot) {
                            final senderName = snapshot.data ?? 'Loading...';
                            return Text(
                              senderName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSender
                                    ? Colors.white.withOpacity(0.9)
                                    : isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[700],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message.content,
                          style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                            color: isSender
                                ? Colors.white
                                : isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(message.timestamp.toDate()),
                              style: TextStyle(
                                fontSize: 10,
                                color: isSender
                                    ? Colors.white70
                                    : isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                              ),
                            ),
                            if (isSender) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.done_all,
                                size: 12,
                                color: Colors.white70,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isSender)
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(left: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 16, color: Colors.white),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer(bool isDarkMode, ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.emoji_emotions_outlined),
              color: AppColors.primary,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emoji picker coming soon!'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: _cachedChatTitle != null
                        ? 'Message $_cachedChatTitle...'
                        : 'Type a message...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                  maxLines: 5,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) {
                    if (_isComposing) {
                      _sendMessage(chatProvider);
                    }
                  },
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _sendButtonController,
              builder: (context, child) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _sendButtonController,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: _isComposing ? AppColors.primary : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                  onPressed: _isComposing ? () => _sendMessage(chatProvider) : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getChatDetails(ChatProvider chatProvider) async {
    if (_cachedChatTitle != null) {
      return {
        'name': _cachedChatTitle!,
        'avatar': _otherUserAvatar,
        'status': null,
      };
    }

    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).get();
    final chatData = chatDoc.data();

    if (widget.isGroup) {
      final groupName = chatData?['groupName'] ?? 'Group Chat';
      return {'name': groupName, 'avatar': null, 'status': 'Group chat'};
    }

    if (chatData?['participants'] != null) {
      final participants = List<String>.from(chatData!['participants']);

      String? currentUserId = chatProvider.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        currentUserId = prefs.getString('userId');
        if (currentUserId == null || currentUserId.isEmpty) {
          logger.e('Current user ID is null or empty');
          return {'name': 'Unknown User', 'avatar': null, 'status': 'Private chat'};
        }
      }

      String? otherUserId;
      for (final participantId in participants) {
        if (participantId != currentUserId) {
          otherUserId = participantId;
          break;
        }
      }

      if (otherUserId == null) {
        logger.e('Could not find other user ID in participants');
        return {'name': 'Unknown User', 'avatar': null, 'status': 'Private chat'};
      }

      try {
        String? apartmentName = chatProvider.currentApartmentName;
        if (apartmentName == null || apartmentName.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          apartmentName = prefs.getString('userApartment');
          if (apartmentName == null || apartmentName.isEmpty) {
            logger.e('Apartment name is null or empty');
            throw Exception('Apartment name not found');
          }
        }

        logger.d('Fetching user document for ID: $otherUserId in apartment: $apartmentName');

        final userDoc = await FirebaseFirestore.instance
            .collection('apartments')
            .doc(apartmentName)
            .collection('users')
            .doc(otherUserId)
            .get();

        if (userDoc.exists && userDoc.data()?['name'] != null) {
          final userName = userDoc.data()?['name'] as String;
          final userAvatar = userDoc.data()?['profilePicture'] as String?;
          final userStatus = userDoc.data()?['status'] as String?;

          return {
            'name': userName,
            'avatar': userAvatar,
            'status': userStatus ?? 'Private chat',
          };
        }
      } catch (e) {
        logger.e('Error in approach 1: $e');
      }

      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();

        if (userDoc.exists && userDoc.data()?['name'] != null) {
          final userName = userDoc.data()?['name'] as String;
          final userAvatar = userDoc.data()?['profilePicture'] as String?;
          final userStatus = userDoc.data()?['status'] as String?;

          return {
            'name': userName,
            'avatar': userAvatar,
            'status': userStatus ?? 'Private chat',
          };
        }
      } catch (e) {
        logger.e('Error in approach 2: $e');
      }

      try {
        if (chatData.containsKey('otherUserName')) {
          final userName = chatData['otherUserName'] as String;
          final userAvatar = chatData['otherUserAvatar'] as String?;

          return {
            'name': userName,
            'avatar': userAvatar,
            'status': 'Private chat',
          };
        }
      } catch (e) {
        logger.e('Error in approach 3: $e');
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final userName = prefs.getString('userName');
        if (userName != null && userName.isNotEmpty) {
          return {
            'name': 'Chat Partner',
            'avatar': null,
            'status': 'Private chat',
          };
        }
      } catch (e) {
        logger.e('Error in approach 4: $e');
      }
    }

    return {'name': 'Chat Partner', 'avatar': null, 'status': 'Private chat'};
  }
}