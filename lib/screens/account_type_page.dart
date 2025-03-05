import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AccountTypePage extends StatelessWidget {
  const AccountTypePage({super.key});

  Widget _buildAccountTypeButton(
    BuildContext context, 
    String title, 
    String accountType
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _selectAccountType(context, accountType),
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

  Future<void> _selectAccountType(BuildContext context, String accountType) async {
    try {
      final authService = AuthService();
      await authService.updateUserAccountType(accountType);
      
      // Navigate to the appropriate signup page
      switch (accountType) {
        case 'resident':
          Navigator.pushNamed(context, '/resident-signup');
          break;
        case 'manager':
          Navigator.pushNamed(context, '/manager-signup');
          break;
        case 'service_provider':
          Navigator.pushNamed(context, '/service-provider-signup');
          break;
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating account type: ${error.toString()}')),
      );
    }
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
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 48),
              // Heading
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
              // Account Type Buttons
              _buildAccountTypeButton(
                context,
                'Apartment Residents',
                'resident',
              ),
              _buildAccountTypeButton(
                context,
                'Apartment Manager',
                'manager',
              ),
              _buildAccountTypeButton(
                context,
                'Service Providers',
                'service_provider',
              ),
              // Back to Login Button
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

