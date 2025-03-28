import 'package:cloud_firestore/cloud_firestore.dart';
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
  
  // Cache for user names to avoid repeated Firestore queries
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
    
    // Check if the widget is still mounted before using context
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
                  // Navigate to login page
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
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
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
          // Personal chats tab
          _buildChatListTab(context, isDarkMode, chatProvider, false),
          
          // Group chats tab (placeholder for now)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group,
                  size: 64,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Group Chats Coming Soon',
                  style: AppTextStyles.getSubtitleStyle.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new chat page
          _showNewChatDialog(context, isDarkMode);
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
      stream: chatProvider.getChats(),
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
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'No chats available' : 'No chats match your search',
                  style: AppTextStyles.getSubtitleStyle.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'Start a new conversation by tapping the button below'
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
            
            // Debug info
            logger.d('Building chat item for chat ID: ${chat.id}');
            logger.d('Participants: ${chat.participants}');
            
            return FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserData(chat, chatProvider),
              builder: (context, userDataSnapshot) {
                // Debug info for name snapshot
                if (userDataSnapshot.hasError) {
                  logger.e('Error fetching user data: ${userDataSnapshot.error}');
                }
                
                final userData = userDataSnapshot.data ?? {'name': 'Loading...', 'avatar': null};
                final name = userData['name'] as String;
                
                // Filter out chats that don't match the search query
                if (_searchQuery.isNotEmpty && 
                    !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
                  return const SizedBox.shrink(); // Hide this chat item
                }
                
                return _buildChatItem(
                  context, 
                  isDarkMode, 
                  chat, 
                  name,
                  userData['avatar'] as String?,
                  userDataSnapshot.connectionState == ConnectionState.waiting,
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
  ) {
    // Get the first letter of the name for the avatar
    final firstLetter = name.isNotEmpty && name != 'Loading...' ? name[0].toUpperCase() : '?';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
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
              builder: (context) => ChatScreen(chatId: chat.id, isGroup: false),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isLoading 
                        ? (isDarkMode ? Colors.grey[700] : Colors.grey[300])
                        : AppColors.primary.withValues(alpha: 0.8),
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
                      : avatarUrl != null && avatarUrl.isNotEmpty
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
                              child: Text(
                                firstLetter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                ),
                const SizedBox(width: 12),
                // Chat details
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
                // Status indicator - online/offline or new message
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

  // This method tries multiple approaches to fetch the user data
  Future<Map<String, dynamic>> _fetchUserData(Chat chat, ChatProvider chatProvider) async {
    // Check cache first
    final cacheKey = chat.id;
    if (_userNameCache.containsKey(cacheKey)) {
      return {'name': _userNameCache[cacheKey]!, 'avatar': null};
    }
    
    if (chat.participants.length != 2) {
      return {'name': 'Group Chat', 'avatar': null};
    }
    
    try {
      // Get current user ID from ChatProvider or SharedPreferences
      String? currentUserId = chatProvider.currentUserId;
      if (currentUserId == null || currentUserId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        currentUserId = prefs.getString('userId');
        if (currentUserId == null || currentUserId.isEmpty) {
          logger.e('Current user ID is null or empty');
          return {'name': 'Unknown User', 'avatar': null};
        }
      }
      
      // Find the other user's ID
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
      
      // Get apartment name from ChatProvider or SharedPreferences
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
      
      // Try multiple approaches to get the user name
      
      // Approach 1: Try the apartments/[apartment]/users collection
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
      
      // Approach 2: Try the global users collection
      try {
        final userDoc = await FirebaseFirestore.instance
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
        logger.e('Error in approach 2: $e');
      }
      
      // Approach 3: Try to get the user name from the chat document itself
      try {
        final chatDoc = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chat.id)
            .get();
        
        if (chatDoc.exists && chatDoc.data()?['otherUserName'] != null) {
          final userName = chatDoc.data()?['otherUserName'] as String;
          _userNameCache[cacheKey] = userName;
          return {'name': userName, 'avatar': null};
        }
      } catch (e) {
        logger.e('Error in approach 3: $e');
      }
      
      // Approach 4: Try to get the user name from SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final userName = prefs.getString('userName');
        if (userName != null && userName.isNotEmpty) {
          // This is a fallback that might not be accurate, but better than nothing
          _userNameCache[cacheKey] = 'Chat with User';
          return {'name': 'Chat with User', 'avatar': null};
        }
      } catch (e) {
        logger.e('Error in approach 4: $e');
      }
      
      // If all approaches fail, return a default name
      return {'name': 'User', 'avatar': null};
    } catch (e, stackTrace) {
      logger.e('Error fetching user data: $e');
      logger.e('Stack trace: $stackTrace');
      return {'name': 'Unknown User', 'avatar': null};
    }
  }
  
  void _showNewChatDialog(BuildContext context, bool isDarkMode) {
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
                  color: AppColors.primary.withValues(alpha: 0.1),
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
                // Show coming soon message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group chats coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}