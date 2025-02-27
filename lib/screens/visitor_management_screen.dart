import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:we_neighbour/components/app_bar.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/constants/colors.dart';

class VisitorManagementScreen extends StatelessWidget {
  const VisitorManagementScreen({super.key});

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
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Visitor Management',
                style: AppTextStyles.getGreetingStyle(isDarkMode),
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
                  color: isDarkMode ? AppColors.darkCardBackground : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: 'https://weneighbour.com/visitor',
                  version: QrVersions.auto,
                  size: 180.0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
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
                  backgroundColor: isDarkMode ? AppColors.primary : const Color(0xFF4285F4),
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Generate QR',
                  style: AppTextStyles.getButtonTextStyle(isDarkMode),
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Camera FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add camera functionality here
        },
        backgroundColor: isDarkMode ? AppColors.primary : const Color(0xFF4285F4),
        child: Icon(
          Icons.camera_alt,
          color: isDarkMode ? AppColors.darkTextPrimary : Colors.white,
        ),
      ),
    );
  }
}