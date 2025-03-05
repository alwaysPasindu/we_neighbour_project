import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_utils.dart'; // Add this import

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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please enter both email and password');
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final headers = {'Content-Type': 'application/json'};
      print('Login request headers: $headers');
      print('Login request body: ${jsonEncode({'email': email, 'password': password})}');
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 15),
          onTimeout: () => throw TimeoutException('Login request timed out'));

      print('Login status code: ${response.statusCode}');
      print('Login response body: ${response.body}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        if (data.containsKey('token') && data.containsKey('user')) {
          await AuthUtils.updateUserDataOnLogin(data); // Use AuthUtils to store data
          print('Stored token: ${data['token']}');
          print('Stored user role: ${data['user']['role']}');

          final role = data['user']['role'].toString().toLowerCase();
          UserType userType;
          switch (role) {
            case 'resident':
              userType = UserType.resident;
              break;
            case 'manager':
              userType = UserType.manager;
              break;
            case 'serviceprovider':
            case 'service_provider':
            case 'provider':
              userType = UserType.serviceProvider;
              break;
            default:
              _showErrorDialog('Invalid user role: $role');
              setState(() => _isLoading = false);
              return;
          }

          if (_rememberMe) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('rememberMe', true);
            await prefs.setString('savedEmail', email);
          } else {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('rememberMe', false);
            await prefs.remove('savedEmail');
          }

          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              userType == UserType.serviceProvider ? '/provider-home' : '/home',
              arguments: userType,
            );
          }
        } else {
          _showErrorDialog('Invalid response from server');
        }
      } else {
        final message = data['message'] ?? 'An error occurred';
        _showErrorDialog(response.statusCode == 400 ? message : 'Server error: $message');
      }
    } on TimeoutException {
      print('Login request timed out');
      _showErrorDialog('Request timed out. Please check your network and try again.');
    } catch (e) {
      print('Error during login: $e');
      _showErrorDialog('Network error: ${e.toString()}');
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
      body: Stack(
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.33),
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
                ],
              ),
            ),
          ),
        ],
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