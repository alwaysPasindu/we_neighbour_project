import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/chat_room.dart';
import '../../models/chat_user.dart';
import '../../services/firebase_service.dart';
import '../../providers/user_provider.dart';
import 'chat_room_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseService _firebaseService = FirebaseService();
  Stream<List<ChatRoom>>? _chatRoomsStream;
  List<ChatUser> _allUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.firebaseUser;

      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _error = 'Please log in to access the chat';
        });
        return;
      }

      // Initialize the chat rooms stream
      _chatRoomsStream = _firebaseService.getChatRoomsForUser(currentUser.uid);
      
      // Load all users
      final users = await _firebaseService.getUsers();
      if (mounted) {
        setState(() {
          _allUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load chat rooms: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _createNewChat() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.firebaseUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a chat')),
      );
      return;
    }

    final users = _allUsers.where((user) => user.id != currentUser.uid).toList();
    
    if (users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users available to chat with')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start a new chat'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? Text(user.name[0].toUpperCase())
                      : null,
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final roomId = await _firebaseService.createChatRoom(
                      [currentUser.uid, user.id],
                    );
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoomPage(
                          roomId: roomId,
                          otherUser: user,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create chat: ${e.toString()}')),
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _initializeChat();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading chats...'),
                ],
              ),
            )
          : _error != null
              ? _buildErrorWidget(_error!)
              : StreamBuilder<List<ChatRoom>>(
                  stream: _chatRoomsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return _buildErrorWidget(snapshot.error.toString());
                    }

                    final chatRooms = snapshot.data ?? [];

                    if (chatRooms.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No conversations yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _createNewChat,
                              icon: const Icon(Icons.add),
                              label: const Text('Start a new chat'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _initializeChat,
                      child: ListView.builder(
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          final room = chatRooms[index];
                          final currentUser = Provider.of<UserProvider>(context, listen: false).firebaseUser;
                          final otherUserId = room.participantIds
                              .firstWhere((id) => id != currentUser?.uid, orElse: () => '');
                          
                          final otherUser = _allUsers.firstWhere(
                            (user) => user.id == otherUserId,
                            orElse: () => ChatUser(
                              id: otherUserId,
                              name: 'Unknown User',
                              email: '',
                            ),
                          );

                          final isUnread = !(room.readStatus[currentUser?.uid ?? ''] ?? true);

                          return ListTile(
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage: otherUser.avatarUrl.isNotEmpty
                                      ? NetworkImage(otherUser.avatarUrl)
                                      : null,
                                  child: otherUser.avatarUrl.isEmpty
                                      ? Text(otherUser.name[0].toUpperCase())
                                      : null,
                                ),
                                if (otherUser.status == UserStatus.online)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              otherUser.name,
                              style: TextStyle(
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              room.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat.jm().format(room.lastMessageTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isUnread ? Theme.of(context).primaryColor : Colors.grey,
                                  ),
                                ),
                                if (isUnread) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      '1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomPage(
                                    roomId: room.id,
                                    otherUser: otherUser,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        child: const Icon(Icons.chat),
      ),
    );
  }
}

