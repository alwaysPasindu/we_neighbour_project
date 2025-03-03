import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

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

  void _handleLogin() async {
    // Validate inputs first
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Please enter both email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    try {
      // Check network connectivity first
      try {
        final result = await http.get(Uri.parse('http://172.20.10.3:3000/health'));
        print('Server health check: ${result.statusCode}');
      } catch (e) {
        print('Server health check failed: $e');
        _showErrorDialog('Unable to connect to server. Please check your connection.');
        setState(() => _isLoading = false);
        return;
      }

      // Make the POST request to the backend
      final response = await http.post(
        Uri.parse('http://172.20.10.3:3000/api/auth/login'), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      // Debug response
      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      // Try to parse response body
      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
        print('Parsed data: $data');
      } catch (e) {
        print('Error parsing response: $e');
        _showErrorDialog('Invalid response from server');
        return;
      }

      if (response.statusCode == 200) {
        if (data.containsKey('token') && data.containsKey('user')) {
          final user = data['user'] as Map<String, dynamic>;
          final token = data['token'] as String;
        
          // Debug user data
          print('User data: $user');
          print('Token: $token');
        
          // Get role from user data
          final role = user['role']?.toString().toLowerCase();
          print('User role: $role');

          if (role == null) {
            _showErrorDialog('User role not found');
            return;
          }

          // Map role to UserType
          UserType userType;
          switch (role) {
            case 'resident':
              userType = UserType.resident;
              break;
            case 'manager':
              userType = UserType.manager;
              break;
            case 'service_provider':
            case 'serviceprovider':
            case 'provider':
              userType = UserType.serviceProvider;
              break;
            default:
              print('Unknown role: $role');
              _showErrorDialog('Invalid user role: $role');
              return;
          }

          // Store user data in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('userId', user['id'] ?? '');
          await prefs.setString('userName', user['name'] ?? '');
          await prefs.setString('userEmail', user['email'] ?? '');
          await prefs.setString('userRole', role);

          // Store additional user data if available
          if (user.containsKey('phone')) {
            await prefs.setString('userPhone', user['phone'] ?? '');
          }
          if (user.containsKey('apartment')) {
            await prefs.setString('userApartment', user['apartment'] ?? '');
          }
          if (user.containsKey('address')) {
            await prefs.setString('userAddress', user['address'] ?? '');
          }
          if (user.containsKey('serviceType')) {
            await prefs.setString('serviceType', user['serviceType'] ?? '');
          }

          // Store remember me preference
          if (_rememberMe) {
            await prefs.setBool('rememberMe', true);
            await prefs.setString('savedEmail', email);
          } else {
            await prefs.setBool('rememberMe', false);
            await prefs.remove('savedEmail');
          }


          // Navigate based on user type
          if (userType == UserType.serviceProvider) {
            Navigator.pushReplacementNamed(context, '/provider-home');
          } else {
            Navigator.pushReplacementNamed(
              context, 
              '/home',
              arguments: userType,
            );
          }
        } else {
          print('Invalid response structure. Data: $data');
          _showErrorDialog('Invalid response from server');
        }
      } else if (response.statusCode == 400) {
        final message = data['message'] ?? 'Invalid credentials';
        _showErrorDialog(message);
      } else {
        final message = data['message'] ?? 'An error occurred';
        _showErrorDialog('Server error: $message');
      }
    } on TimeoutException {
      print('Request timed out');
      _showErrorDialog('Request timed out. Please try again.');
    } catch (e) {
      print('Error during login: $e');
      _showErrorDialog('Network error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _handleSocialLogin(String platform) {
    // TODO: Implement social login logic
    print('$platform login attempted');
    
    // For now, just show a message that this feature is not implemented
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
                color: const Color(0xFF2B5BA9),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [
                          const Color.fromARGB(255, 0, 18, 152),
                          const Color(0xFF2B5BA9).withOpacity(0.8),
                        ]
                      : [
                          const Color.fromARGB(255, 14, 105, 213),
                          const Color(0xFF4285F4),
                        ],
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/white.png',
                  width: 170,
                  height: 170,
                ),
              ),
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
                      color: isDarkMode 
                          ? const Color(0xFF2A2F35)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? const Color(0xFF2A2F35)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autocorrect: false,
                      enableSuggestions: false,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: isDarkMode ? Colors.white60 : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
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
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return const Color.fromARGB(255, 0, 18, 152);
                                }
                                return isDarkMode ? Colors.white38 : const Color.fromARGB(255, 233, 232, 232);
                              },
                            ),
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : const Color.fromARGB(221, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Forgot password feature coming soon')),
                          );
                        },
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'New user?',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/account-type');
                        },
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
                      Expanded(
                        child: Divider(
                          color: isDarkMode ? Colors.white38 : Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDarkMode ? Colors.white38 : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sign in with another account',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
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
          border: Border.all(
            color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
          ),
          color: isDarkMode ? const Color(0xFF2A2F35) : Colors.white,
        ),
        child: Image.asset(
          iconPath,
          height: 24,
          width: 24,
        ),
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
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

