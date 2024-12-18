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
          Text('CHOOSE YOUR ACCOUNT TYPE',
              style: AppTheme.titleStyle.copyWith(color: Colors.black)),
          const SizedBox(height: 20),
          _buildAccountTypeButton('Apartment Residents'),
          _buildAccountTypeButton('Apartment Manager'),
          _buildAccountTypeButton('Service Providers'),
        ],
      ),
    );
  }

  Widget _buildAccountTypeButton(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () {},
        child: Center(
          child: Text(title, style: AppTheme.bodyStyle.copyWith(color: Colors.white)),
        ),
      ),
    );
  }
}
