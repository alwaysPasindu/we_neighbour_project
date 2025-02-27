import 'package:flutter/material.dart';
import 'package:we_neighbour/components/app_bar.dart';
import 'package:we_neighbour/constants/text_styles.dart';

class SafetyAlertsScreen extends StatelessWidget {
  const SafetyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color.fromARGB(255, 146, 4, 4) : const Color.fromARGB(255, 146, 4, 4),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onBackPressed: () => Navigator.pop(context),
              isDarkMode: isDarkMode,
            ),

            // Safety Alerts heading
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'SAFETY ALERTS',
                style: AppTextStyles.getGreetingStyle(isDarkMode),
              ),
            ),
            const SizedBox(height: 40),

            // Alert cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigate to new screen when card is tapped
                      Navigator.pushNamed(context, '/new-screen');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      height: 120,
                      child: const Center(
                        child: Text(
                          'Tap to view details',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
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