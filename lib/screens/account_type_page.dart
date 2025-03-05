import 'package:flutter/material.dart';

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({super.key});

  Widget _buildAccountTypeButton(
      BuildContext context, String title, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A237E),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 48),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 48),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'CHOOSE YOUR\nACCOUNT TYPE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 64),
              _buildAccountTypeButton(
                context,
                'Apartment Residents',
                () => Navigator.pushNamed(context, '/resident-signup'),
              ),
              _buildAccountTypeButton(
                context,
                'Apartment Manager',
                () => Navigator.pushNamed(context, '/manager-signup'),
              ),
              _buildAccountTypeButton(
                context,
                'Service Providers',
                () => Navigator.pushNamed(context, '/service-provider-signup'),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}