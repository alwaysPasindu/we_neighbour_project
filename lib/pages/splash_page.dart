import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Use relative imports
import '../services/auth_service.dart';
import '../services/mongodb_service.dart';
import 'login_page.dart';
import 'chat_list_page.dart';
import 'debug_page.dart';
import 'auth_debug_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isSyncing = false;
  String _syncStatus = '';
  bool _showDebug = false;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _syncUsersAndRedirect();
  }

  Future<void> _syncUsersAndRedirect() async {
    setState(() {
      _isSyncing = true;
      _syncStatus = 'Initializing...';
    });

    try {
      // Check for JWT token
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getToken();
      
      if (token != null) {
        setState(() {
          _syncStatus = 'Found authentication token';
        });
      } else {
        setState(() {
          _syncStatus = 'No authentication token found';
        });
      }
      
      // Sync MongoDB users to Firestore
      setState(() {
        _syncStatus = 'Syncing MongoDB users...';
      });
      
      final mongoDBService = Provider.of<MongoDBService>(context, listen: false);
      final users = await mongoDBService.fetchAndSyncUsers();
      
      setState(() {
        _syncStatus = 'Synced ${users.length} users successfully';
      });
    } catch (e) {
      // Continue even if sync fails
      setState(() {
        _syncStatus = 'Error syncing users: $e';
      });
      print('Error syncing users: $e');
    } finally {
      setState(() {
        _isSyncing = false;
      });
      
      // Short delay to show the status
      await Future.delayed(const Duration(seconds: 2));
      
      if (!_showDebug && mounted) {
        _redirect();
      }
    }
  }

  Future<void> _redirect() async {
    if (!mounted) return;
    
    final authService = Provider.of<AuthService>(context, listen: false);
    
    if (authService.currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ChatListPage()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _incrementTapCount() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 5) {
        _showDebug = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _incrementTapCount,
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Flutter Chat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_isSyncing) 
              const CircularProgressIndicator()
            else if (_showDebug)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const DebugPage()),
                      );
                    },
                    child: const Text('MongoDB Debug'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const AuthDebugPage()),
                      );
                    },
                    child: const Text('Auth Debug'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _redirect,
                    child: const Text('Continue to App'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _redirect,
                child: const Text('Continue'),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _syncStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

