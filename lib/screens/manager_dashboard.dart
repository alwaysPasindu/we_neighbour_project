import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ResidentsRequestScreen extends StatefulWidget {
  const ResidentsRequestScreen({super.key});

  @override
  State<ResidentsRequestScreen> createState() => _ResidentsRequestScreenState();
}

class _ResidentsRequestScreenState extends State<ResidentsRequestScreen> {
  static const String baseUrl = 'https://we-neighbour-app-9modf.ondigitalocean.app';
  bool _isLoading = true;
  List<dynamic> _pendingResidents = [];
  Map<String, bool> _processing = {}; // Tracks which resident is being processed

  @override
  void initState() {
    super.initState();
    _fetchPendingResidents();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchPendingResidents() async {
    final token = await _getToken();

    if (token == null) {
      _showErrorDialog('Authentication error. Please login again.');
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/residents/pending'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      ).timeout(const Duration(seconds: 10));

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pendingResidents = data['pendingRessidents'] as List<dynamic>;
          _processing = {for (var resident in _pendingResidents) resident['_id']: false};
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await _signOut();
      } else {
        _showErrorDialog('Failed to fetch pending residents: ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _handleRequest(String residentId, String status) async {
    final token = await _getToken();
    if (token == null) {
      _showErrorDialog('Authentication error. Please login again.');
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
      return;
    }

    setState(() => _processing[residentId] = true);

    try {
      final Map<String, dynamic> requestBody = {
        'residentId': residentId,
        'status': status,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/residents/check'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      setState(() => _processing[residentId] = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Resident request $status successfully')),
          );
          // Remove the resident from the list after approval/rejection
          setState(() {
            _pendingResidents.removeWhere((r) => r['_id'] == residentId);
          });
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await _signOut();
      } else {
        _showErrorDialog('Failed to $status resident: ${response.body}');
      }
    } catch (e) {
      setState(() => _processing[residentId] = false);
      _showErrorDialog('Network error: $e');
    }
  }

  Future<void> _signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
    await prefs.remove('userId');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pending Resident Requests'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingResidents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No pending resident requests',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPendingResidents,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingResidents.length,
                  itemBuilder: (context, index) {
                    final resident = _pendingResidents[index];
                    final residentId = resident['_id'];
                    final isProcessing = _processing[residentId] ?? false;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resident['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Email: ${resident['email'] ?? 'No email'}'),
                            Text('NIC: ${resident['nic'] ?? 'No NIC'}'),
                            Text('Address: ${resident['address'] ?? 'No address'}'),
                            Text('Phone: ${resident['phone'] ?? 'No phone'}'),
                            Text('Apartment Code: ${resident['apartmentCode'] ?? 'No code'}'),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: isProcessing
                                      ? null
                                      : () => _handleRequest(residentId, 'approved'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A7C59),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: isProcessing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Approve'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: isProcessing
                                      ? null
                                      : () => _handleRequest(residentId, 'rejected'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B2E2E),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: isProcessing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text('Decline'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}