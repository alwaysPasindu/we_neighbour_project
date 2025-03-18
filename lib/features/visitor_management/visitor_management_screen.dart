import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({super.key});

  @override
  State<VisitorManagementScreen> createState() => _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen> {
  String? qrData;
  bool isLoading = false;
  final _numOfVisitorsController = TextEditingController();
  final _visitorNamesController = TextEditingController();
  static const String baseUrl = 'https://we-neighbour-backend.vercel.app'; // Your backend IP
  final GlobalKey _qrKey = GlobalKey(); // Key for capturing QR image

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Retrieved token: $token');
    if (token == null) {
      const mockToken = 'mock-token-123'; // Temporary mock token
      await prefs.setString('token', mockToken);
      print('Set mock token: $mockToken');
      return mockToken;
    }
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
              decoration: const InputDecoration(
                labelText: 'Number of Visitors',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _visitorNamesController,
              decoration: const InputDecoration(
                labelText: 'Visitor Names (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (_numOfVisitorsController.text.isEmpty || _visitorNamesController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }
              try {
                final numOfVisitors = int.parse(_numOfVisitorsController.text);
                Navigator.pop(context, {
                  'numOfVisitors': numOfVisitors,
                  'visitorNames': _visitorNamesController.text.split(',').map((name) => name.trim()).toList(),
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Number of Visitors must be a valid number')),
                );
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (result == null) return;

    setState(() => isLoading = true);

    try {
      final token = await getAuthToken();
      if (token == null) throw Exception('No authentication token found');

      final response = await http.post(
        Uri.parse('$baseUrl/api/visitor/generate-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'residentId': 'resident123', // Replace with actual resident ID if available
          'numOfVisitors': result['numOfVisitors'],
          'visitorNames': result['visitorNames'],
        }),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final qrJson = {
          'visitorId': data['visitorId'].toString(),
          'residentId': 'resident123',
          'numOfVisitors': result['numOfVisitors'],
          'visitorNames': result['visitorNames'],
        };
        setState(() => qrData = json.encode(qrJson));
        print('Generated QR data: $qrData');
      } else {
        throw Exception('Failed to generate QR code: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error generating QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => qrData = null);
    } finally {
      setState(() => isLoading = false);
      _numOfVisitorsController.clear();
      _visitorNamesController.clear();
    }
  }

  Future<void> downloadQRCode() async {
    if (qrData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code to download')),
      );
      return;
    }

    try {
      // Capture the QR code as an image
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'VisitorQR_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareFiles(
        [filePath],
        text: 'Here is your visitor QR code for apartment access.',
        subject: 'Visitor QR Code',
      );
    } catch (e) {
      print('Error downloading QR code: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading QR code: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor QR Code'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (qrData == null && !isLoading) ...[
                  const Text(
                    'Generate a Visitor QR Code',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: generateQRCode,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Generate QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
                if (isLoading) const CircularProgressIndicator(color: Colors.blueAccent),
                if (qrData != null) ...[
                  RepaintBoundary(
                    key: _qrKey,
                    child: QrImageView(
                      data: qrData!,
                      version: QrVersions.auto,
                      size: 250.0,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: downloadQRCode,
                    icon: const Icon(Icons.share),
                    label: const Text('Download QR Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}