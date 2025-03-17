import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'debug_page.dart';

class AuthDebugPage extends StatefulWidget {
  const AuthDebugPage({super.key});

  @override
  State<AuthDebugPage> createState() => _AuthDebugPageState();
}

class _AuthDebugPageState extends State<AuthDebugPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _apiEndpointController = TextEditingController(
    text: '/chat-residents'
  );
  
  String _debugOutput = '';
  String _token = '';
  bool _isLoading = false;
  bool _showPassword = false;
  
  @override
  void initState() {
    super.initState();
    _checkExistingToken();
  }
  
  Future<void> _checkExistingToken() async {
    setState(() {
      _debugOutput = 'Checking for existing token...\n';
    });
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = await authService.getToken();
    
    setState(() {
      if (token != null) {
        _token = token;
        _debugOutput += 'Found existing token: ${_formatToken(token)}\n';
      } else {
        _debugOutput += 'No existing token found.\n';
      }
    });
  }
  
  String _formatToken(String token) {
    if (token.length <= 20) return token;
    return '${token.substring(0, 10)}...${token.substring(token.length - 10)}';
  }
  
  Future<void> _authenticate() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _debugOutput += 'Please enter both email and password.\n';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _debugOutput += '\nAttempting authentication with ${_emailController.text}...\n';
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.authenticateWithBackendOnly(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      final token = await authService.getToken();
      
      setState(() {
        if (token != null) {
          _token = token;
          _debugOutput += 'Authentication successful!\n';
          _debugOutput += 'Token: ${_formatToken(token)}\n';
        } else {
          _debugOutput += 'Authentication failed. No token received.\n';
        }
      });
    } catch (e) {
      setState(() {
        _debugOutput += 'Error during authentication: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _testApiEndpoint() async {
    if (_apiEndpointController.text.isEmpty) {
      setState(() {
        _debugOutput += 'Please enter an API endpoint to test.\n';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _debugOutput += '\nTesting API endpoint: ${_apiEndpointController.text}...\n';
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final result = await authService.testApiCall(_apiEndpointController.text);
      
      setState(() {
        _debugOutput += 'Status code: ${result['status']}\n';
        
        if (result['success']) {
          _debugOutput += 'Request successful!\n';
        } else {
          _debugOutput += 'Request failed.\n';
        }
        
        if (result['error'] != null) {
          _debugOutput += 'Error: ${result['error']}\n';
        }
        
        _debugOutput += 'Response data:\n';
        if (result['data'] is Map || result['data'] is List) {
          _debugOutput += const JsonEncoder.withIndent('  ').convert(result['data']) + '\n';
        } else {
          _debugOutput += '${result['data']}\n';
        }
      });
    } catch (e) {
      setState(() {
        _debugOutput += 'Error testing API endpoint: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _clearToken() async {
    setState(() {
      _isLoading = true;
      _debugOutput += '\nClearing token...\n';
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      
      setState(() {
        _token = '';
        _debugOutput += 'Token cleared successfully.\n';
      });
    } catch (e) {
      setState(() {
        _debugOutput += 'Error clearing token: $e\n';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _apiEndpointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DebugPage()),
              );
            },
            tooltip: 'MongoDB Debug',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backend Authentication',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _authenticate,
                  child: const Text('Authenticate'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _token.isEmpty || _isLoading ? null : _clearToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Clear Token'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Test API Endpoint',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _apiEndpointController,
                    decoration: const InputDecoration(
                      labelText: 'API Endpoint',
                      border: OutlineInputBorder(),
                      hintText: '/chat-residents',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _testApiEndpoint,
                  child: const Text('Test'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Debug Output',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: SelectableText(_debugOutput),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

