import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://we-neighbour-backend.vercel.app/api/users'
  );
  String _responseText = 'No response yet';
  bool _isLoading = false;
  int _statusCode = 0;
  
  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
  
  Future<void> _testApi() async {
    setState(() {
      _isLoading = true;
      _responseText = 'Loading...';
      _statusCode = 0;
    });
    
    try {
      final response = await http.get(
        Uri.parse(_urlController.text),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      setState(() {
        _statusCode = response.statusCode;
        _responseText = _formatJson(response.body);
      });
    } catch (e) {
      setState(() {
        _responseText = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  String _formatJson(String jsonString) {
    try {
      final object = json.decode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(object);
    } catch (e) {
      return jsonString;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'API URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testApi,
                  child: const Text('Test API'),
                ),
                const SizedBox(width: 16),
                if (_statusCode > 0)
                  Text(
                    'Status: $_statusCode',
                    style: TextStyle(
                      color: _statusCode >= 200 && _statusCode < 300
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Response:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
                        child: SelectableText(_responseText),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

