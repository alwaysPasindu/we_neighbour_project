import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart';

enum UserType { resident, manager, serviceProvider }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  static const String baseUrl = 'http://172.20.10.3:3000';

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        final savedEmail = prefs.getString('savedEmail');
        if (savedEmail != null && savedEmail.isNotEmpty) {
          setState(() {
            _emailController.text = savedEmail;
            _rememberMe = true;
          });
        }
      }
    } catch (e) {
      print('Error loading saved email: $e');
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text, 'password': _passwordController.text}),
      );

      print('Login request headers: ${response.request?.headers}');
      print('Login request body: {"email":"${_emailController.text}","password":"${_passwordController.text}"}');
      print('Login status code: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body);
      print('Parsed response data: $data');

      if (response.statusCode == 200 || response.statusCode == 403) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Clear stale data
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['user']['id']);
        await prefs.setString('userRole', data['user']['role'].toLowerCase());
        await prefs.setString('userName', data['user']['name'] ?? 'User');
        await prefs.setString('userEmail', data['user']['email'] ?? 'N/A');
        await prefs.setString('userStatus', data['user']['status'] ?? 'approved');
        await prefs.setString('apartmentComplexName', data['user']['apartmentComplexName'] ?? 'N/A');

        if (_rememberMe) {
          await prefs.setString('savedEmail', _emailController.text);
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('savedEmail');
          await prefs.setBool('rememberMe', false);
        }

        final role = data['user']['role'].toLowerCase();
        final status = data['user']['status'];

        if (role == 'resident' && status == 'approved') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (role == 'manager') {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (role == 'serviceprovider') {
          Navigator.pushReplacementNamed(context, '/provider-home');
        } else if (status == 'pending') {
          Navigator.pushReplacementNamed(context, '/pending-approval');
        }
      } else {
        _showErrorDialog('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      _showErrorDialog('Network error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleSocialLogin(String platform) {
    print('$platform login attempted');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$platform login is not implemented yet')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color.fromARGB(255, 0, 0, 0) : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.39,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [const Color.fromARGB(255, 0, 18, 152), const Color(0xFF2B5BA9).withOpacity(0.8)]
                        : [const Color.fromARGB(255, 14, 105, 213), const Color(0xFF4285F4)],
                  ),
                ),
                child: Center(child: Image.asset('assets/images/white.png', width: 170, height: 170)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'WELCOME!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2A2F35) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black54),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2A2F35) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black54),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: isDarkMode ? Colors.white60 : Colors.grey,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) => setState(() => _rememberMe = value ?? false),
                            fillColor: MaterialStateProperty.resolveWith(
                              (states) => states.contains(MaterialState.selected)
                                  ? const Color.fromARGB(255, 0, 18, 152)
                                  : (isDarkMode ? Colors.white38 : const Color.fromARGB(255, 233, 232, 232)),
                            ),
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(color: isDarkMode ? Colors.white : const Color.fromARGB(221, 0, 0, 0)),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Forgot password feature coming soon')),
                        ),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 170, 170, 170),
                            fontWeight: isDarkMode ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 18, 152),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Login', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New user?',
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/account-type'),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: const Color(0xFF2B5BA9),
                            fontWeight: isDarkMode ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Divider(color: isDarkMode ? Colors.white38 : Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OR',
                          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                        ),
                      ),
                      Expanded(child: Divider(color: isDarkMode ? Colors.white38 : Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in with another account',
                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton('assets/images/facebook.png', () => _handleSocialLogin('Facebook'), isDarkMode),
                      const SizedBox(width: 16),
                      _socialButton('assets/images/google.png', () => _handleSocialLogin('Google'), isDarkMode),
                      const SizedBox(width: 16),
                      _socialButton('assets/images/twitter.png', () => _handleSocialLogin('Twitter'), isDarkMode),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(String iconPath, VoidCallback onPressed, bool isDarkMode) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isDarkMode ? Colors.white24 : Colors.grey[300]!),
          color: isDarkMode ? const Color(0xFF2A2F35) : Colors.white,
        ),
        child: Image.asset(iconPath, height: 24, width: 24),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.75);
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}