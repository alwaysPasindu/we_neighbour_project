import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/main.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _animationController.forward();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        final savedEmail = prefs.getString('savedEmail');
        if (savedEmail != null && savedEmail.isNotEmpty) {
          if (!mounted) return;
          setState(() {
            _emailController.text = savedEmail;
            _rememberMe = true;
          });
        }
      }
    } catch (e) {
      logger.d('Error loading saved email: $e');
    }
  }

  Future<void> _handleLogin() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final client = IOClient(httpClient);

      final response = await client
          .post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      )
          .timeout(const Duration(seconds: 50), onTimeout: () {
        throw TimeoutException('Request timed out after 50 seconds');
      });

      logger.d('Response status: ${response.statusCode}');
      logger.d('Raw response body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 403) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['user']['id']);
        await prefs.setString('userRole', data['user']['role'].toLowerCase());
        await prefs.setString('userName', data['user']['name'] ?? 'User');
        await prefs.setString('userEmail', data['user']['email'] ?? 'N/A');
        await prefs.setString('userStatus', data['user']['status'] ?? 'approved');
        await prefs.setString(
            'apartmentComplexName', data['user']['apartmentComplexName'] ?? 'N/A');

        if (_rememberMe) {
          await prefs.setString('savedEmail', _emailController.text);
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('savedEmail');
          await prefs.setBool('rememberMe', false);
        }

        final role = data['user']['role'].toLowerCase();
        final status = data['user']['status'];

        if (!mounted) return;

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
        if (!mounted) return;
        _showErrorDialog('Login failed', data['message'] ?? 'Invalid credentials');
      }
    } catch (e, stackTrace) {
      logger.d('Login error: $e');
      logger.d('Stack trace: $stackTrace');
      if (!mounted) return;
      _showErrorDialog('Connection Error', 'Unable to connect to the server: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('OK',
                style: TextStyle(color: Color.fromARGB(255, 0, 18, 152), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    const primaryColor = Color.fromARGB(255, 0, 18, 152);
    const secondaryColor = Color.fromARGB(255, 14, 105, 213);

    final headerHeight = size.height * 0.35;
    final contentPadding =
        EdgeInsets.symmetric(horizontal: size.width < 360 ? 20.0 : 24.0, vertical: 12.0);
    final logoSize = size.width < 360 ? 110.0 : 130.0;
    final titleFontSize = size.width < 360 ? 30.0 : 34.0;
    final buttonHeight = size.width < 360 ? 48.0 : 52.0;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.grey[100],
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: -size.width * 0.4,
            right: -size.width * 0.3,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 0.2,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          primaryColor.withValues(alpha: 0.7),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - padding.top),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(scale: _scaleAnimation.value, child: child);
                    },
                    child: ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        height: headerHeight,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDarkMode
                                ? [primaryColor, secondaryColor.withValues(alpha: 0.8)]
                                : [secondaryColor, const Color(0xFF4285F4)],
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10)),
                          ],
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    0, math.sin(_animationController.value * math.pi * 2) * 5),
                                child: child,
                              );
                            },
                            child: Hero(
                              tag: 'app_logo',
                              child: Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                child: Image.asset('assets/images/white.png',
                                    width: logoSize, height: logoSize),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: contentPadding,
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(opacity: _fadeAnimation.value, child: child),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'WELCOME!',
                              style: TextStyle(
                                fontSize: 34.0, // Default size for larger screens
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white70 : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.025),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    !_isEmailValid ? Colors.red.withValues(alpha: 0.8) : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enableSuggestions: false,
                                autocorrect: false,
                                onChanged: (value) {
                                  if (!_isEmailValid) setState(() => _isEmailValid = true);
                                },
                                style:
                                    TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  hintStyle:
                                      TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey[500]),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: size.width < 360 ? 16 : 18),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: isDarkMode ? primaryColor.withValues(alpha: 0.9) : primaryColor,
                                      size: 22),
                                  suffixIcon: !_isEmailValid
                                      ? const Icon(Icons.error_outline, color: Colors.red, size: 22)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          if (!_isEmailValid)
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 8),
                              child: Text('Please enter a valid email',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                          SizedBox(height: size.height * 0.015),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    !_isPasswordValid ? Colors.red.withValues(alpha: 0.8) : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                onChanged: (value) {
                                  if (!_isPasswordValid) setState(() => _isPasswordValid = true);
                                },
                                style:
                                    TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  hintStyle:
                                      TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey[500]),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: size.width < 360 ? 16 : 18),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.lock_outline,
                                      color: isDarkMode ? primaryColor.withValues(alpha: 0.9) : primaryColor,
                                      size: 22),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!_isPasswordValid)
                                        const Icon(Icons.error_outline, color: Colors.red, size: 22),
                                      IconButton(
                                        icon: Icon(
                                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                            color: isDarkMode ? Colors.white60 : Colors.grey,
                                            size: 22),
                                        onPressed: () =>
                                            setState(() => _obscurePassword = !_obscurePassword),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!_isPasswordValid)
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 8),
                              child: Text('Password must be at least 6 characters',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        onChanged: (value) =>
                                            setState(() => _rememberMe = value ?? false),
                                        fillColor: WidgetStateProperty.resolveWith(
                                          (states) => states.contains(WidgetState.selected)
                                              ? primaryColor
                                              : (isDarkMode ? Colors.white38 : Colors.grey.shade300),
                                        ),
                                        shape:
                                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Remember me',
                                        style: TextStyle(
                                            color: isDarkMode ? Colors.white70 : Colors.grey[800],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Forgot password feature coming soon'),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(16),
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  child: Text('Forgot password?',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          Container(
                            height: buttonHeight,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _isLoading
                                    ? [
                                        primaryColor.withValues(alpha: 0.7),
                                        secondaryColor.withValues(alpha: 0.7),
                                      ]
                                    : [primaryColor, secondaryColor],
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4)),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child:
                                            CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text('Login',
                                              style: TextStyle(
                                                  fontSize: 18, // Default size for larger screens
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 1.1)),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward_rounded,
                                              color: Colors.white, size: 20), // Default size
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.015),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('New user?',
                                    style: TextStyle(
                                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                                TextButton(
                                  onPressed: () {
                                    if (!mounted) return;
                                    Navigator.pushNamed(context, '/account-type');
                                  },
                                  style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  child: Text('Register',
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.8);

    var firstStart = Offset(size.width / 4, size.height);
    var firstEnd = Offset(size.width / 2.25, size.height * 0.9);
    path.quadraticBezierTo(firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart = Offset(size.width / 1.5, size.height * 0.8);
    var secondEnd = Offset(size.width, size.height * 0.9);
    path.quadraticBezierTo(secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}