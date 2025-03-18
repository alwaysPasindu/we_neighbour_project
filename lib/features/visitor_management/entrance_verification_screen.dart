import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class EntranceVerificationScreen extends StatefulWidget {
  const EntranceVerificationScreen({super.key});

  @override
  State<EntranceVerificationScreen> createState() => _EntranceVerificationScreenState();
}

class _EntranceVerificationScreenState extends State<EntranceVerificationScreen> {
  bool isVerifying = false;
  String? errorMessage;
  static const String baseUrl = 'https://we-neighbour-backend.vercel.app'; // Match VisitorManagementScreen

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      const mockToken = 'mock-token-123'; // Same mock token as above
      await prefs.setString('token', mockToken);
      print('Set mock token: $mockToken');
      return mockToken;
    }
    print('Retrieved token: $token');
    return token;
  }

  Future<void> scanAndVerifyQRCode() async {
    setState(() {
      errorMessage = null;
      isVerifying = false;
    });

    try {
      final result = await BarcodeScanner.scan();
      print('Raw QR content: ${result.rawContent}');

      final qrData = json.decode(result.rawContent) as Map<String, dynamic>;
      print('Parsed QR data: $qrData');

      final visitorId = qrData['visitorId']?.toString();
      final visitorNames = qrData['visitorNames'] is List
          ? (qrData['visitorNames'] as List).join(', ')
          : 'Unknown';
      final numOfVisitors = qrData['numOfVisitors']?.toString() ?? 'Unknown';

      if (visitorId == null) {
        throw Exception('Invalid QR code: visitorId missing');
      }

      final action = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Visitor Verification',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 50, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text('Visitor: $visitorNames', style: const TextStyle(fontSize: 18)),
              Text('Count: $numOfVisitors', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Approve', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, 'reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Decline', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      );

      if (action != null) {
        setState(() => isVerifying = true);

        final token = await getAuthToken();
        if (token == null) throw Exception('No authentication token found');

        final response = await http.post(
          Uri.parse('$baseUrl/api/visitor/update-status'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'visitorId': visitorId, 'action': action}),
        ).timeout(const Duration(seconds: 10));

        print('Update status response: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          final message = action == 'accept' ? 'Entry Approved' : 'Entry Declined';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: action == 'accept' ? Colors.green : Colors.red,
            ),
          );
        } else {
          throw Exception('Failed to update status: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Error during QR scan/verification: $e');
      setState(() => errorMessage = 'Error: $e');
    } finally {
      setState(() => isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrance Verification'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueAccent.shade100, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Scan Visitor QR Code',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blueAccent),
                const SizedBox(height: 30),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: isVerifying ? null : scanAndVerifyQRCode,
                  icon: isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    textStyle: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}