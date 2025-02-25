import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidContact(String contact) {
    return RegExp(r'^(?:\+94|0)?[0-9]{9}$').hasMatch(contact);
  }

  bool _isStrongPassword(String password) {
    return RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      print('Company Name: ${_companyNameController.text}');
      print('Email: ${_emailController.text}');
      print('Service Type: ${_serviceTypeController.text}');
      print('Contact: ${_contactController.text}');
      
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/provider-home',
        (route) => false,
      );
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
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
                    'Service Provider Sign Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    hint: 'Company Name/Your Name',
                    controller: _companyNameController,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Company name is required';
                      }
                      if (value.length < 2) {
                        return 'Please enter a valid company name';
                      }
                      return null;
                    },
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
                      if (!_isValidEmail(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    hint: 'Service Type',
                    controller: _serviceTypeController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Service type is required';
                      }
                      if (value.length < 3) {
                        return 'Please enter a valid service type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    hint: 'Contact No',
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contact number is required';
                      }
                      if (!_isValidContact(value)) {
                        return 'Please enter a valid contact number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    hint: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (!_isStrongPassword(value)) {
                        return 'Password must contain uppercase, lowercase, number and special character';
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
                  const SizedBox(height: 24),

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
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        ),
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