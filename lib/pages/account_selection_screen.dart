import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AccountSelectionScreen extends StatelessWidget {
  const AccountSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: Image.asset(
              'assets/images/logo.jpeg',
              width: 100,
              height: 100,
            ),
          ),
          Text('CHOOSE YOUR ACCOUNT TYPE',
              style: AppTheme.titleStyle.copyWith(color: Colors.black)),
          const SizedBox(height: 20),
          _buildAccountTypeButton('Apartment Residents', () {
            Navigator.pushNamed(context, '/profile');
          }),
          _buildAccountTypeButton('Apartment Manager', () {
            Navigator.pushNamed(context, '/manager_profile');
          }),
          _buildAccountTypeButton('Service Providers', () {
            Navigator.pushNamed(context, '/company_profile');
          }),
        ],
      ),
    );
  }

  Widget _buildAccountTypeButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(title, style: AppTheme.bodyStyle.copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}

