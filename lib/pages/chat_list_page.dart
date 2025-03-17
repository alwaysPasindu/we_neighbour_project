import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';

// Use relative imports
import '../services/firestore_service.dart';
import '../services/mongodb_service.dart';
import '../models/profile.dart';
import '../components/avatar.dart';
import 'chat_page.dart';
import 'account_page.dart';
import 'debug_page.dart'; // Add debug page

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _isLoading = true;
  late final String _currentUserId;
  final Map<String, bool> _onlineUsers = {};
  final Map<String, DateTime?> _lastSeen = {};
  bool _showMongoDBUsersOnly = false;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _updateUserPresence(true);
    _refreshMongoDBUsers();
  }

  Future<void> _updateUserPresence(bool isOnline) async {
    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      await firestoreService.updateUserPresence(_currentUserId, isOnline);
    } catch (e) {
      // Silently handle presence update errors
    }
  }

  Future<void> _refreshMongoDBUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final mongoDBService = Provider.of<MongoDBService>(context, listen: false);
      await mongoDBService.fetchAndSyncUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error syncing MongoDB users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _incrementTapCount() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DebugPage()),
        );
        _tapCount = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _incrementTapCount,
          child: const Text('Chats'),
        ),
        actions: [
          // Toggle to show MongoDB users only
          IconButton(
            icon: Icon(
              _showMongoDBUsersOnly ? Icons.filter_list : Icons.filter_list_off,
              color: _showMongoDBUsersOnly ? Colors.blue : null,
            ),
            tooltip: 'Toggle MongoDB users only',
            onPressed: () {
              setState(() {
                _showMongoDBUsersOnly = !_showMongoDBUsersOnly;
              });
            },
          ),
          // Refresh MongoDB users
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh MongoDB users',
            onPressed: _refreshMongoDBUsers,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AccountPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Profile>>(
              stream: _showMongoDBUsersOnly 
                  ? firestoreService.getMongoDBUsers() 
                  : firestoreService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final profiles = snapshot.data ?? [];
                
                if (profiles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No users found'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshMongoDBUsers,
                          child: const Text('Refresh MongoDB Users'),
                        ),
                      ],
                    ),
                  );
                }
                
                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: firestoreService.getAllUserPresences(),
                  builder: (context, presenceSnapshot) {
                    if (presenceSnapshot.hasData) {
                      final presenceData = presenceSnapshot.data ?? [];
                      
                      for (final presence in presenceData) {
                        final userId = presence['user_id'] as String;
                        _onlineUsers[userId] = presence['status'] == 'online';
                        
                        if (presence['last_seen'] != null) {
                          _lastSeen[userId] = (presence['last_seen'] as Timestamp).toDate();
                        }
                      }
                    }
                    
                    return RefreshIndicator(
                      onRefresh: _refreshMongoDBUsers,
                      child: ListView.builder(
                        itemCount: profiles.length,
                        itemBuilder: (context, index) {
                          final profile = profiles[index];
                          final isOnline = _onlineUsers[profile.id] ?? false;
                          final lastSeen = _lastSeen[profile.id];
                          final isMongoDBUser = profile.source == 'mongodb';
                          
                          return ListTile(
                            leading: Stack(
                              children: [
                                Avatar(
                                  imageUrl: profile.avatarUrl,
                                  radius: 20,
                                ),
                                if (isOnline)
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
                                if (isMongoDBUser)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
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
                            title: Row(
                              children: [
                                Text(profile.username),
                                if (isMongoDBUser)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'MongoDB',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOnline 
                                      ? 'Online' 
                                      : lastSeen != null 
                                          ? 'Last seen ${timeago.format(lastSeen)}'
                                          : 'Offline',
                                  style: TextStyle(
                                    color: isOnline ? Colors.green : Colors.grey,
                                  ),
                                ),
                                if (profile.apartmentComplexName != null && 
                                    profile.apartmentComplexName!.isNotEmpty)
                                  Text(
                                    profile.apartmentComplexName!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                            isThreeLine: profile.apartmentComplexName != null && 
                                         profile.apartmentComplexName!.isNotEmpty,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatPage(
                                    receiverProfile: profile,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _updateUserPresence(false);
    super.dispose();
  }
}

