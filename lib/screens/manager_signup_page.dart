import 'package:flutter/material.dart';

class ManagerSignUpPage extends StatefulWidget {
  const ManagerSignUpPage({super.key});

  @override
  State<ManagerSignUpPage> createState() => _ManagerSignUpPageState();
}

class _ManagerSignUpPageState extends State<ManagerSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _apartmentNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _apartmentNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement sign up logic
      print('Name: ${_nameController.text}');
      print('NIC: ${_nicController.text}');
      print('Email: ${_emailController.text}');
      print('Contact: ${_contactController.text}');
      print('Address: ${_addressController.text}');
      print('Apartment Name: ${_apartmentNameController.text}');
      
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
                  const SizedBox(height: 10),

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

