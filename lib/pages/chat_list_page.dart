import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

// Use relative imports
import '../services/firestore_service.dart';
import '../models/profile.dart';
import '../components/avatar.dart';
import 'chat_page.dart';
import 'account_page.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _updateUserPresence(true);
  }

  Future<void> _updateUserPresence(bool isOnline) async {
    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      await firestoreService.updateUserPresence(_currentUserId, isOnline);
    } catch (e) {
      // Silently handle presence update errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
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
      body: StreamBuilder<List<Profile>>(
        stream: firestoreService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final profiles = snapshot.data ?? [];
          
          if (profiles.isEmpty) {
            return const Center(child: Text('No users found'));
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
                onRefresh: () async {
                  // Refresh is handled by the stream
                  return;
                },
                child: ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    final isOnline = _onlineUsers[profile.id] ?? false;
                    final lastSeen = _lastSeen[profile.id];
                    
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
                        ],
                      ),
                      title: Text(profile.username),
                      subtitle: Text(
                        isOnline 
                            ? 'Online' 
                            : lastSeen != null 
                                ? 'Last seen ${timeago.format(lastSeen)}'
                                : 'Offline',
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
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

