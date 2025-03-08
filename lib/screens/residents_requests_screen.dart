import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/app_bar.dart';
import '../constants/colors.dart';

class ResidentsRequestsScreen extends StatefulWidget {
  const ResidentsRequestsScreen({super.key});

  @override
  State<ResidentsRequestsScreen> createState() => _ResidentsRequestsScreenState();
}

class _ResidentsRequestsScreenState extends State<ResidentsRequestsScreen> {
  static const String baseUrl = 'http://172.20.10.3:3000';
  List<dynamic> pendingResidents = [];
  bool _isLoading = true;

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
      print('No token found, navigating to login');
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

      print('Fetch pending residents response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pendingResidents = data['pendingResidents'] ?? [];
          _isLoading = false;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Unauthorized or forbidden, signing out');
        await _signOut();
      } else {
        _showErrorDialog('Failed to fetch pending residents: ${response.body}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching pending residents: $e');
      _showErrorDialog('Network error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRequest(String residentId, String status) async {
    final token = await _getToken();
    if (token == null) {
      print('No token found, navigating to login');
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/residents/check'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'residentId': residentId,
          'status': status,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Approval response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resident request $status successfully')),
        );
        // Remove the resident from the list after approval/rejection
        setState(() {
          pendingResidents.removeWhere((resident) => resident['_id'] == residentId);
        });
      } else {
        _showErrorDialog('Failed to $status resident: ${response.body}');
      }
    } catch (e) {
      print('Error handling request: $e');
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onBackPressed: () => Navigator.pop(context),
              isDarkMode: isDarkMode,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Residents\' Requests',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : pendingResidents.isEmpty
                      ? Center(
                          child: Text(
                            'No pending requests',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pendingResidents.length,
                          itemBuilder: (context, index) {
                            final resident = pendingResidents[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDarkMode
                                        ? Colors.black.withOpacity(0.4)
                                        : Colors.grey.withOpacity(0.4),
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.person_add,
                                            color: AppColors.primary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                resident['name'] ?? 'Unnamed Resident',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode ? Colors.white : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                resident['email'] ?? 'No email',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDarkMode
                                                      ? AppColors.darkTextSecondary
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Pending',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.black.withOpacity(0.2)
                                          : Colors.grey.shade50,
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: isDarkMode
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Submitted recently', // Replace with actual timestamp if available
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDarkMode
                                                    ? AppColors.darkTextSecondary
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () => _handleRequest(resident['_id'], 'approved'),
                                              child: const Text(
                                                'Approve',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            GestureDetector(
                                              onTap: () => _handleRequest(resident['_id'], 'rejected'),
                                              child: const Text(
                                                'Reject',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}