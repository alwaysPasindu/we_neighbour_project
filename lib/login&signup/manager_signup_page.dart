import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:we_neighbour/main.dart'; // Assuming baseUrl is defined here
import 'package:logger/logger.dart'; // Added logger import

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
  bool _isLoading = false;
  final Logger logger = Logger(); // Added logger instance

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

  bool _isValidName(String name) => RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  bool _isValidNIC(String nic) => RegExp(r'^\d{9}[Vv]$|^\d{12}$').hasMatch(nic);
  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  bool _isValidContact(String contact) =>
      RegExp(r'^(?:\+94|0)?[0-9]{9}$').hasMatch(contact);
  bool _isStrongPassword(String password) =>
      password.length >= 6 &&
      RegExp(r'[0-9]').hasMatch(password) &&
      RegExp(r'[a-zA-Z]').hasMatch(password);

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final managerData = {
        'name': _nameController.text.trim(),
        'nic': _nicController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _contactController.text.trim(),
        'address': _addressController.text.trim(),
        'apartmentName': _apartmentNameController.text.trim(),
        'password': _passwordController.text.trim(),
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/managers/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(managerData),
        );

        final responseData = json.decode(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ??
                    'Manager registered successfully!')),
          );
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ??
                    'Failed to sign up: ${response.body}')),
          );
          logger.d('Failed to sign up. Error: ${response.body}'); // Replaced print
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
        logger.d('Network error: $e'); // Replaced print
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
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
        enableSuggestions: false,
        autocorrect: false,
        textInputAction: TextInputAction.next,
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
        inputFormatters: inputFormatters,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        ),
        validator: validator,
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
                    'Manager Sign Up',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    hint: 'Name',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                    ],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Name is required'
                        : !_isValidName(value)
                            ? 'Please enter a valid name (letters only)'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'NIC',
                    controller: _nicController,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9Vv]'))
                    ],
                    validator: (value) => value == null || value.isEmpty
                        ? 'NIC is required'
                        : !_isValidNIC(value)
                            ? 'Please enter a valid NIC number'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Email is required'
                        : !_isValidEmail(value)
                            ? 'Please enter a valid email address'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Contact No',
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Contact number is required'
                        : !_isValidContact(value)
                            ? 'Please enter a valid contact number'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Address',
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Address is required'
                        : value.length < 5
                            ? 'Please enter a valid address'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Apartment Name',
                    controller: _apartmentNameController,
                    keyboardType: TextInputType.text,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Apartment name is required'
                        : value.length < 3
                            ? 'Please enter a valid apartment name'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password is required'
                        : !_isStrongPassword(value)
                            ? 'Password must be at least 6 characters with a letter and number'
                            : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Sign Up',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ',
                          style: TextStyle(color: Colors.black87)),
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false),
                        child: const Text('Sign in',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
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