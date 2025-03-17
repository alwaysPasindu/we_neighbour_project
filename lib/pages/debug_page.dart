import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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
  final TextEditingController _apiUrlController = TextEditingController(
    text: 'https://we-neighbour-backend.vercel.app/chat-residents'
  );
  String _apiResponse = '';
  bool _testingApi = false;

  @override
  void initState() {
    super.initState();
    _checkFirestoreUsers();
  }
  
  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _testApi() async {
    setState(() {
      _testingApi = true;
      _apiResponse = 'Testing API...';
    });
    
    try {
      final response = await http.get(
        Uri.parse(_apiUrlController.text),
        headers: {'Content-Type': 'application/json'},
      );
      
      setState(() {
        _apiResponse = 'Status: ${response.statusCode}\n\n';
        
        try {
          final jsonData = json.decode(response.body);
          _apiResponse += const JsonEncoder.withIndent('  ').convert(jsonData);
        } catch (e) {
          _apiResponse += 'Raw response: ${response.body}';
        }
      });
    } catch (e) {
      setState(() {
        _apiResponse = 'Error: $e';
      });
    } finally {
      setState(() {
        _testingApi = false;
      });
    }
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
            const Text(
              'Test API Endpoint:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _apiUrlController,
                    decoration: const InputDecoration(
                      hintText: 'API URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _testingApi ? null : _testApi,
                  child: const Text('Test'),
                ),
              ],
            ),
            if (_apiResponse.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                height: 150,
                child: SingleChildScrollView(
                  child: SelectableText(_apiResponse),
                ),
              ),
            ],
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

