import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VisitorManagementScreen extends StatelessWidget {
  const VisitorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              
              const SizedBox(height: 20),
              
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/white.png',
                  height: 60, // Adjust the height as needed
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Visitor Management Text
              const Center(
                child: Text(
                  'Visitor\nManagement',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // QR Code
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: QrImageView(
                    data: 'https://weneighbour.com/visitor',
                    version: QrVersions.auto,
                    size: 180.0,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Generate QR Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Add QR generation logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Generate QR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
      // Camera FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add camera functionality here
        },
        backgroundColor: const Color(0xFF4285F4),
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}