import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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

  String _accountType = 'resident';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      _accountType = args;
    }
  }

  String get _getTitle {
    switch (_accountType) {
      case 'resident':
        return 'Resident Sign Up';
      case 'manager':
        return 'Manager Sign Up';
      case 'provider':
        return 'Provider Sign Up';
      default:
        return 'Sign Up';
    }
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

  bool _isValidName(String name) {
    return RegExp(r'^[a-zA-Z\s]+$').hasMatch(name);
  }

  bool _isValidNIC(String nic) {
    return RegExp(r'^\d{9}[Vv]$|^\d{12}$').hasMatch(nic);
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
      print('Name: ${_nameController.text}');
      print('NIC: ${_nicController.text}');
      print('Email: ${_emailController.text}');
      print('Contact: ${_contactController.text}');
      print('Address: ${_addressController.text}');
      print('Apartment: $_selectedApartment');
      
      Navigator.pop(context);
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

                  Text(
                    _getTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildTextField(
                    hint: 'Name',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Name is required';
                      }
                      if (!_isValidName(value)) {
                        return 'Please enter a valid name (letters only)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    hint: 'NIC',
                    controller: _nicController,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9Vv]')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'NIC is required';
                      }
                      if (!_isValidNIC(value)) {
                        return 'Please enter a valid NIC number';
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
                    hint: 'Address',
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address is required';
                      }
                      if (value.length < 5) {
                        return 'Please enter a valid address';
                      }
                      return null;
                    },
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
                        'Select Apartment',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        border: InputBorder.none,
                        errorStyle: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
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
                        onTap: () => Navigator.pop(context),
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