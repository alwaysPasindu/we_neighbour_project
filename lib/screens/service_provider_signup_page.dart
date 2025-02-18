import 'package:flutter/material.dart';

class ServiceProviderSignUpPage extends StatefulWidget {
  const ServiceProviderSignUpPage({super.key});

  @override
  State<ServiceProviderSignUpPage> createState() => _ServiceProviderSignUpPageState();
}

class _ServiceProviderSignUpPageState extends State<ServiceProviderSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _serviceTypeController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement sign up logic
      print('Company Name: ${_companyNameController.text}');
      print('Email: ${_emailController.text}');
      print('Service Type: ${_serviceTypeController.text}');
      print('Contact: ${_contactController.text}');
      
      // Navigate to home screen after successful signup
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // ... rest of the code remains the same

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ... other widgets remain the same

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ... rest of the widgets remain the same
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

