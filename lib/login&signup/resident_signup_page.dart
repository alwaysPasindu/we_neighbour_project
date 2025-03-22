import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:we_neighbour/main.dart';

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
  List<String> _apartments = [];
  bool _isLoading = false;
  bool _isFetchingApartments = true;

  @override
  void initState() {
    super.initState();
    _fetchApartments();
  }

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

  Future<void> _fetchApartments() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/api/apartments/get-names'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _apartments = List<String>.from(data['apartmentNames']);
          _isFetchingApartments = false;
        });
      } else {
        throw 'Failed to fetch apartments: ${response.statusCode}';
      }
    } catch (e) {
      print('Error fetching apartments: $e');
      setState(() => _isFetchingApartments = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load apartments: $e')));
    }
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
      var formData = {
        'name': _nameController.text.trim(),
        'nic': _nicController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _contactController.text.trim(),
        'address': _addressController.text.trim(),
        'apartmentComplexName': _selectedApartment,
        'apartmentCode': _addressController.text.trim(),
        'password': _passwordController.text.trim(),
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/residents/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(formData),
        );

        final responseData = json.decode(response.body);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ??
                    'Resident registered successfully! Awaiting approval')),
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
          print('Failed to sign up. Error: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
        print('Error occurred: $e');
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
          color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
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
        child: _isFetchingApartments
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                            child: Image.asset('assets/images/logo.png',
                                height: 80, fit: BoxFit.contain)),
                        const SizedBox(height: 24),
                        const Text('Resident Sign Up',
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        const SizedBox(height: 24),
                        _buildTextField(
                          hint: 'Name',
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z\s]'))
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
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9Vv]'))
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) => value == null || value.isEmpty
                              ? 'Contact number is required'
                              : !_isValidContact(value)
                                  ? 'Please enter a valid contact number'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          hint: 'Apartment Code (Address)',
                          controller: _addressController,
                          keyboardType: TextInputType.streetAddress,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Apartment code is required'
                              : value.length < 2
                                  ? 'Please enter a valid apartment code'
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12)),
                          child: DropdownButtonFormField<String>(
                            value: _selectedApartment,
                            hint: Text('Select Apartment Complex',
                                style: TextStyle(color: Colors.grey[600])),
                            decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                border: InputBorder.none,
                                errorStyle:
                                    TextStyle(color: Colors.red, fontSize: 12)),
                            items: _apartments
                                .map((String apartment) =>
                                    DropdownMenuItem<String>(
                                        value: apartment,
                                        child: Text(apartment)))
                                .toList(),
                            onChanged: (String? newValue) =>
                                setState(() => _selectedApartment = newValue),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Please select an apartment complex'
                                : null,
                          ),
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
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A237E),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Sign Up',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 16),
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
