// features/chat/chat_list_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/models/chat.dart';
import 'package:we_neighbour/providers/chat_provider.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'package:logger/logger.dart';
import 'chat_screen.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with SingleTickerProviderStateMixin {
  final logger = Logger();
  late TabController _tabController;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Map<String, String> _userNameCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _syncUserData();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      logger.w('User is not authenticated');
    } else {
      logger.d('User is authenticated: ${user.uid}');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId') ?? '';
  final apartmentName = prefs.getString('userApartment') ?? 'UnknownApartment';

  logger.d('Syncing user data from SharedPreferences:');
  logger.d('userId: $userId');
  logger.d('apartmentName: $apartmentName');

  // Check if apartment name matches Firebase
  if (apartmentName != 'Negombo-Dreams') {
    logger.w('Apartment name does not match Firebase: $apartmentName');
  }

  if (!mounted) return;

  final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  if (userId.isNotEmpty && chatProvider.currentUserId != userId) {
    chatProvider.setUser(userId, apartmentName);
    logger.d('Updated ChatProvider with userId: $userId, apartmentName: $apartmentName');
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Please log in to view chats',
                style: AppTextStyles.getSubtitleStyle.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
                autofocus: true,
              )
            : Text(
                'Chats',
                style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(color: Colors.white),
              ),
        backgroundColor: AppColors.primary,
        elevation: 2,
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatListTab(context, isDarkMode, chatProvider, false),
          _buildChatListTab(context, isDarkMode, chatProvider, true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatDialog(context, isDarkMode, chatProvider);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  Widget _buildChatListTab(BuildContext context, bool isDarkMode, ChatProvider chatProvider, bool isGroup) {
    return Column(
      children: [
        Expanded(
          child: _buildChatList(context, isDarkMode, chatProvider, isGroup),
        ),
      ],
    );
  }

  Widget _buildChatList(BuildContext context, bool isDarkMode, ChatProvider chatProvider, bool isGroup) {
    return StreamBuilder<List<Chat>>(
      stream: isGroup ? chatProvider.getGroupChats() : chatProvider.getChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  'Loading chats...',
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading chats',
                  style: AppTextStyles.getSubtitleStyle.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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

        final chats = snapshot.data ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isGroup ? Icons.group : Icons.chat_bubble_outline,
                  size: 64,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? (isGroup ? 'No group chats available' : 'No chats available')
                      : 'No chats match your search',
                  style: AppTextStyles.getSubtitleStyle.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'Start a new ${isGroup ? 'group' : 'conversation'} by tapping the button below'
                      : 'Try a different search term',
                  style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Search'),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: chats.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final chat = chats[index];

            logger.d('Building chat item for chat ID: ${chat.id}');
            logger.d('Participants: ${chat.participants}');

            return FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserData(chat, chatProvider, isGroup),
              builder: (context, userDataSnapshot) {
                if (userDataSnapshot.hasError) {
                  logger.e('Error fetching user data: ${userDataSnapshot.error}');
                }

                final userData = userDataSnapshot.data ?? {'name': 'Loading...', 'avatar': null};
                final name = userData['name'] as String;

                if (_searchQuery.isNotEmpty && !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
                  return const SizedBox.shrink();
                }

                return _buildChatItem(
                  context,
                  isDarkMode,
                  chat,
                  name,
                  userData['avatar'] as String?,
                  userDataSnapshot.connectionState == ConnectionState.waiting,
                  isGroup,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    bool isDarkMode,
    Chat chat,
    String name,
    String? avatarUrl,
    bool isLoading,
    bool isGroup,
  ) {
    final firstLetter = name.isNotEmpty && name != 'Loading...' ? name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(chatId: chat.id, isGroup: isGroup),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isLoading
                        ? (isDarkMode ? Colors.grey[700] : Colors.grey[300])
                        : AppColors.primary.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                            ),
                          ),
                        )
                      : avatarUrl != null && avatarUrl.isNotEmpty && !isGroup
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Text(
                                      firstLetter,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Icon(
                                isGroup ? Icons.group : Icons.person,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.getSubtitleStyle.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.lastMessage ?? 'No messages yet',
                        style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: chat.lastMessage != null ? Colors.green : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      width: chat.lastMessage != null ? 0 : 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchUserData(Chat chat, ChatProvider chatProvider, bool isGroup) async {
    final cacheKey = chat.id;
    if (_userNameCache.containsKey(cacheKey)) {
      return {'name': _userNameCache[cacheKey]!, 'avatar': null};
    }

    if (isGroup) {
      final groupName = chat.groupName ?? 'Unnamed Group';
      _userNameCache[cacheKey] = groupName;
      return {'name': groupName, 'avatar': null};
    }

    if (chat.participants.length != 2) {
      return {'name': 'Group Chat', 'avatar': null};
    }

    try {
      String? currentUserId = chatProvider.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        currentUserId = prefs.getString('userId');
        if (currentUserId == null || currentUserId.isEmpty) {
          logger.e('Current user ID is null or empty');
          return {'name': 'Unknown User', 'avatar': null};
        }
      }

      String? otherUserId;
      for (final participantId in chat.participants) {
        if (participantId != currentUserId) {
          otherUserId = participantId;
          break;
        }
      }

      if (otherUserId == null) {
        logger.e('Could not find other user ID in participants');
        return {'name': 'Unknown User', 'avatar': null};
      }

      String? apartmentName = chatProvider.currentApartmentName;
      if (apartmentName == null || apartmentName.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        apartmentName = prefs.getString('userApartment');
        if (apartmentName == null || apartmentName.isEmpty) {
          logger.e('Apartment name is null or empty');
          return {'name': 'Unknown User', 'avatar': null};
        }
      }

      logger.d('Fetching user document for ID: $otherUserId in apartment: $apartmentName');

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('apartments')
            .doc(apartmentName)
            .collection('users')
            .doc(otherUserId)
            .get();

        if (userDoc.exists && userDoc.data()?['name'] != null) {
          final userName = userDoc.data()?['name'] as String;
          _userNameCache[cacheKey] = userName;
          return {
            'name': userName,
            'avatar': userDoc.data()?['profilePicture'] as String?,
          };
        }
      } catch (e) {
        logger.e('Error in approach 1: $e');
      }

      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();

        if (userDoc.exists && userDoc.data()?['name'] != null) {
          final userName = userDoc.data()?['name'] as String;
          _userNameCache[cacheKey] = userName;
          return {
            'name': userName,
            'avatar': userDoc.data()?['profilePicture'] as String?,
          };
        }
      } catch (e) {
        logger.e('Error in approach 2: $e');
      }

      return {'name': 'User', 'avatar': null};
    } catch (e, stackTrace) {
      logger.e('Error fetching user data: $e');
      logger.e('Stack trace: $stackTrace');
      return {'name': 'Unknown User', 'avatar': null};
    }
  }

  void _showNewChatDialog(BuildContext context, bool isDarkMode, ChatProvider chatProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Start a New Conversation',
              style: AppTextStyles.getSubtitleStyle.copyWith(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                'New Group Chat',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Create a group conversation',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showCreateGroupDialog(context, isDarkMode, chatProvider);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, bool isDarkMode, ChatProvider chatProvider) {
    final TextEditingController groupNameController = TextEditingController();
    List<Map<String, dynamic>> apartmentUsers = [];
    List<String> selectedUserIds = [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Create Group Chat',
            style: AppTextStyles.getGreetingStyle(isDarkMode),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: groupNameController,
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: chatProvider.getApartmentUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(color: AppColors.primary);
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'Error loading users: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    apartmentUsers = snapshot.data ?? [];
                    if (apartmentUsers.isEmpty) {
                      return const Text(
                        'No users found in your apartment.',
                        style: TextStyle(color: Colors.grey),
                      );
                    }
                    return SizedBox(
                      height: 200,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: apartmentUsers.length,
                        itemBuilder: (context, index) {
                          final user = apartmentUsers[index];
                          return CheckboxListTile(
                            title: Text(
                              user['name'],
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            value: selectedUserIds.contains(user['id']),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedUserIds.add(user['id']);
                                } else {
                                  selectedUserIds.remove(user['id']);
                                }
                              });
                            },
                            activeColor: AppColors.primary,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: AppColors.primary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (groupNameController.text.isEmpty || selectedUserIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a group name and select at least one member'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                try {
                  final chatId = await chatProvider.createGroupChat(
                    groupNameController.text,
                    selectedUserIds,
                  );
                  if (!mounted) return;
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatId: chatId, isGroup: true),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating group: $e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
