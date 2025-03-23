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
import 'package:we_neighbour/main.dart';
import 'package:logger/logger.dart'; // Added logger import

class VisitorManagementScreen extends StatefulWidget {
  const VisitorManagementScreen({super.key});

  @override
  State<VisitorManagementScreen> createState() => _VisitorManagementScreenState();
}

class _VisitorManagementScreenState extends State<VisitorManagementScreen> {
  String? qrData;
  bool isLoading = false;
  final _numOfVisitorsController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  final Logger logger = Logger(); // Added logger instance

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    logger.d('Retrieved token: $token'); // Replaced print
    if (token == null || token.isEmpty) {
      logger.d('No valid token found, redirecting to login'); // Replaced print
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return null;
    }
    return token;
  }

  Future<void> generateQRCode() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Text(
          'Visitor Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: TextField(
          controller: _numOfVisitorsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Number of Visitors',
            labelStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.group, color: Colors.blueAccent),
            filled: true,
            fillColor: Colors.grey[100],
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
            ),
          ),
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_numOfVisitorsController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter the number of visitors')),
                );
                return;
              }
              try {
                final numOfVisitors = int.parse(_numOfVisitorsController.text);
                Navigator.pop(context, numOfVisitors);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid number')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Generate', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result == null) return;

    setState(() => isLoading = true);

    try {
      final token = await getAuthToken();
      if (token == null) {
        throw Exception('Authentication required. Please log in.');
      }

      final prefs = await SharedPreferences.getInstance();
      final residentId = prefs.getString('userId') ?? 'resident123';

      final response = await http.post(
        Uri.parse('$baseUrl/api/visitor/generate-qr'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: json.encode({
          'residentId': residentId,
          'numOfVisitors': result,
        }),
      ).timeout(const Duration(seconds: 10));

      logger.d('Request: ${response.request}'); // Replaced print
      logger.d('Response status: ${response.statusCode}'); // Replaced print
      logger.d('Response body: ${response.body}'); // Replaced print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final visitorId = data['visitorId'];
        // Assuming the apartment name might come from the API or is hardcoded
        final apartmentName = data['apartment'] ?? 'Negombo-Dreams'; // Fallback to hardcoded value if not in response

        // Construct the QR data with query parameters
        setState(() {
          qrData = Uri(
            scheme: 'https',
            host: 'we-neighbour-app-9modf.ondigitalocean.app',
            path: '/api/visitor/verify/$visitorId',
            queryParameters: {'apartment': apartmentName},
          ).toString();
        });
        logger.d('Generated QR data: $qrData'); // Replaced print
      } else {
        throw Exception('Failed to generate QR code: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      logger.d('Error generating QR code: $e'); // Replaced print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => qrData = null);
    } finally {
      setState(() => isLoading = false);
      _numOfVisitorsController.clear();
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
      final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'VisitorQR_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Here is your visitor QR code for apartment access.',
        subject: 'Visitor QR Code',
      );
    } catch (e) {
      logger.d('Error downloading QR code: $e'); // Replaced print
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading QR code: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Generate Visitor QR',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withValues(alpha: 0.5), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (qrData == null && !isLoading) ...[
                      const Icon(Icons.qr_code_2, size: 80, color: Colors.blueAccent),
                      const SizedBox(height: 20),
                      const Text(
                        'Generate Visitor QR Code',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Create a QR code for your visitors.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: generateQRCode,
                        icon: const Icon(Icons.qr_code_scanner, size: 24, color: Colors.white),
                        label: const Text(
                          'Generate QR',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          shadowColor: Colors.blueAccent.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                    if (isLoading) ...[
                      const CircularProgressIndicator(color: Colors.blueAccent),
                      const SizedBox(height: 20),
                      const Text(
                        'Generating your QR code...',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                    if (qrData != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Your Visitor QR Code',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 20),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: downloadQRCode,
                        icon: const Icon(Icons.share, size: 24, color: Colors.white),
                        label: const Text(
                          'Share QR',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          shadowColor: Colors.blue.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}