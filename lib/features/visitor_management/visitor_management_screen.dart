import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:we_neighbour/components/app_bar.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/utils/auth_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({super.key});

  @override
  State<VisitorManagementScreen> createState() => _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen> {
  String? qrCodeUrl;
  bool isLoading = false;
  final _numOfVisitorsController = TextEditingController();
  final _visitorNamesController = TextEditingController();

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Retrieved token from SharedPreferences: $token');
    return token;
  }

  Future<void> generateQRCode() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Visitor Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _numOfVisitorsController,
              keyboardType: TextInputType.number,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Number of Visitors'),
            ),
            TextField(
              controller: _visitorNamesController,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(labelText: 'Visitor Names (comma-separated)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (_numOfVisitorsController.text.isEmpty || _visitorNamesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
                return;
              }
              Navigator.pop(context, {
                'numOfVisitors': int.parse(_numOfVisitorsController.text),
                'visitorNames': _visitorNamesController.text.split(',').map((name) => name.trim()).toList(),
              });
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (result == null) return;

    setState(() => isLoading = true);

    try {
      final isLoggedIn = await AuthUtils.isLoggedIn();
      print('Is user logged in? $isLoggedIn');

      if (!isLoggedIn) {
        throw Exception('User is not logged in. Please log in again.');
      }

      const String apiUrl = '$baseUrl/api/visitor/generate-qr';
      final String? token = await getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please log in again.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      print('Full request headers being sent: $headers');

      final requestBody = {
        'numOfVisitors': result['numOfVisitors'],
        'visitorNames': result['visitorNames'],
      };
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => qrCodeUrl = data['qrImage']);
      } else {
        throw Exception('Failed to generate QR code: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating QR code: $e')));
      if (e.toString().contains('not logged in')) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } finally {
      setState(() => isLoading = false);
      _numOfVisitorsController.clear();
      _visitorNamesController.clear();
    }
  }

  Future<void> saveQRCodeToDevice() async {
    if (qrCodeUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No QR code to save')));
      return;
    }

    try {
      // Get the app's documents directory (cross-platform safe, no permissions needed)
      final directory = await getApplicationDocumentsDirectory();
      if (directory == null) {
        throw Exception('Unable to access documents directory');
      }

      // Generate a unique filename
      final fileName = 'QRCode_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';

      // Decode base64 string (remove "data:image/png;base64," prefix)
      final base64String = qrCodeUrl!.split(',').last;
      final bytes = base64Decode(base64String);

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('QR code saved to $filePath')));
    } catch (e) {
      print('Error saving QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving QR code: $e')));
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
            CustomAppBar(onBackPressed: () => Navigator.pop(context), isDarkMode: isDarkMode),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text('Visitor Management', style: AppTextStyles.getGreetingStyle(isDarkMode)),
            ),
            const SizedBox(height: 40),
            Center(
              child: Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: qrCodeUrl != null
                    ? Image.memory(
                        base64Decode(qrCodeUrl!.split(',').last),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Center(child: Text('Error loading QR')),
                      )
                    : QrImageView(
                        data: 'https://weneighbour.live/visitor',
                        version: QrVersions.auto,
                        size: 180.0,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : generateQRCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? AppColors.primary : const Color(0xFF4285F4),
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Generate QR', style: AppTextStyles.getButtonTextStyle(isDarkMode)),
              ),
            ),
            if (qrCodeUrl != null) ...[
              const SizedBox(height: 20),
              Text("Share this QR code with your visitors", style: AppTextStyles.getBodyTextStyle(isDarkMode)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveQRCodeToDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? AppColors.primary : const Color(0xFF4285F4),
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Text('Save QR Code', style: AppTextStyles.getButtonTextStyle(isDarkMode)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}