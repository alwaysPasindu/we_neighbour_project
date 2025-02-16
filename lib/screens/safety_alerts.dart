import 'package:flutter/material.dart';

class SafetyAlertsScreen extends StatelessWidget {
  const SafetyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar with back button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    // Navigate to new screen
                    Navigator.pushNamed(context, '/new-screen');
                  },
                ),
              ),
            ),

            // Logo
            Image.asset(
              'assets/we_neighbour_logo.png',
              width: 150, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 40),

            // Safety Alerts heading
            const Text(
              'SAFETY ALERTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 24),

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
