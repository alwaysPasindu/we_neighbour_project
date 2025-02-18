import 'package:flutter/material.dart';

class ResidentSignUpPage extends StatefulWidget {
  const ResidentSignUpPage({super.key});

  @override
  State<ResidentSignUpPage> createState() => _ResidentSignUpPageState();
}

class _ResidentSignUpPageState extends State<ResidentSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedApartment;

  final List<String> _apartments = [
    'Green Valley Apartments',
    'Sunset Heights',
    'Palm Grove Residency',
    'Ocean View Complex',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nicController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
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
      print('Apartment: $_selectedApartment');
      
      // Navigate to home screen after successful signup
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          errorStyle: const TextStyle(height: 0),
        ),
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

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
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Resident Sign Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    hint: 'Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'NIC',
                    controller: _nicController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Contact No',
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Address',
                    controller: _addressController,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedApartment,
                      hint: Text(
                        'Apartment Name',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        border: InputBorder.none,
                        errorStyle: TextStyle(height: 0),
                      ),
                      items: _apartments.map((String apartment) {
                        return DropdownMenuItem<String>(
                          value: apartment,
                          child: Text(apartment),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedApartment = newValue;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an apartment';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/'),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

