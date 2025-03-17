import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/mongodb_service.dart';
import 'chat_list_page.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  bool _isLoading = false;
  String _debugOutput = '';
  List<Map<String, dynamic>> _users = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _checkFirestoreUsers();
  }

  Future<void> _syncMongoDBUsers() async {
    setState(() {
      _isLoading = true;
      _debugOutput = 'Syncing MongoDB users...\n';
    });

    try {
      final mongoDBService = Provider.of<MongoDBService>(context, listen: false);
      final users = await mongoDBService.fetchAndSyncUsers();
      
      setState(() {
        _debugOutput += 'Successfully synced ${users.length} users\n';
        _users = users;
      });
    } catch (e) {
      setState(() {
        _debugOutput += 'Error: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _checkFirestoreUsers();
    }
  }

  Future<void> _checkFirestoreUsers() async {
    setState(() {
      _debugOutput += 'Checking Firestore users...\n';
    });

    try {
      // Check main users collection
      final usersSnapshot = await _firestore.collection('users').get();
      setState(() {
        _debugOutput += 'Found ${usersSnapshot.docs.length} users in main collection\n';
      });

      // Check if any users have source: mongodb
      final mongoUsersSnapshot = await _firestore
          .collection('users')
          .where('source', isEqualTo: 'mongodb')
          .get();
      
      setState(() {
        _debugOutput += 'Found ${mongoUsersSnapshot.docs.length} MongoDB users\n';
        
        if (mongoUsersSnapshot.docs.isNotEmpty) {
          _debugOutput += '\nSample MongoDB user:\n';
          _debugOutput += '${mongoUsersSnapshot.docs.first.data()}\n';
        }
      });

      // Check apartments collection
      try {
        final apartmentsSnapshot = await _firestore
            .collection('apartments')
            .doc('ApartmentC')
            .collection('users')
            .get();
        
        setState(() {
          _debugOutput += '\nFound ${apartmentsSnapshot.docs.length} users in apartments/ApartmentC/users\n';
          
          if (apartmentsSnapshot.docs.isNotEmpty) {
            _debugOutput += '\nSample apartment user:\n';
            _debugOutput += '${apartmentsSnapshot.docs.first.data()}\n';
          }
        });
      } catch (e) {
        setState(() {
          _debugOutput += 'Error checking apartments collection: $e\n';
        });
      }
    } catch (e) {
      setState(() {
        _debugOutput += 'Error: $e\n';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug MongoDB Integration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ChatListPage()),
              );
            },
            tooltip: 'Go to Chat',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _syncMongoDBUsers,
                  child: const Text('Sync MongoDB Users'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _checkFirestoreUsers,
                  child: const Text('Check Firestore'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debug Output:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(_debugOutput),
                      ),
                      if (_users.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'MongoDB Users:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            String userId = '';
                            String username = '';
                            
                            // Handle different _id formats
                            if (user['_id'] is Map && user['_id']['\$oid'] != null) {
                              userId = user['_id']['\$oid'].toString();
                            } else {
                              userId = user['_id'].toString();
                            }
                            
                            // Handle different name fields
                            username = user['name'] ?? user['username'] ?? 'Unknown';
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(username),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: $userId'),
                                    if (user['email'] != null)
                                      Text('Email: ${user['email']}'),
                                    if (user['apartmentComplexName'] != null)
                                      Text('Apartment: ${user['apartmentComplexName']}'),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

