import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/main.dart';
import '../utils/auth_utils.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/providers/chat_provider.dart';

String getBaseUrl() {
  return baseUrl;
}

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

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ));

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
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
    final String effectiveBaseUrl = getBaseUrl();
    setState(() => _isLoading = true);
    try {
      print('Running on platform: ${Platform.operatingSystem}');
      print('Attempting login with effective baseUrl: $effectiveBaseUrl');
      print('Login request sent to: $effectiveBaseUrl/api/auth/login');

      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final client = IOClient(httpClient);

      final response = await client.post(
        Uri.parse('$effectiveBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      ).timeout(const Duration(seconds: 50), onTimeout: () {
        throw TimeoutException('Request timed out after 30 seconds');
      });

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Raw response body: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      if (response.statusCode == 504) {
        _showErrorDialog('Server Error', 'The server is temporarily unavailable. Please try again later or contact support.');
        return; // Exit early to avoid parsing the body
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
        await prefs.setString('apartmentComplexName', data['user']['apartmentComplexName'] ?? 'N/A');

        if (_rememberMe) {
          await prefs.setString('savedEmail', _emailController.text);
          await prefs.setBool('rememberMe', true);
        } else {
          await prefs.remove('savedEmail');
          await prefs.setBool('rememberMe', false);
        }

        // Update ChatProvider
        final userId = data['user']['id'];
        final apartmentName = data['user']['apartmentComplexName'] ?? 'Negombo-Dreams';
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        chatProvider.setUser(userId, apartmentName);
        print('Updated ChatProvider after login: userId=$userId, apartmentName=$apartmentName');

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
        _showErrorDialog('Login failed', data['message'] ?? 'Invalid credentials');
      }
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Stack trace: $stackTrace');
      if (e is HandshakeException) {
        print('Handshake details: ${e.message}');
        print('Possible SSL issue with $effectiveBaseUrl (bypassed for development)');
      } else if (e is SocketException) {
        print('Socket details: ${e.message}');
        print('Ensure $effectiveBaseUrl is reachable and CORS is configured');
      } else if (e is FormatException) {
        print('JSON parsing error: ${e.message}');
      } else if (e is TimeoutException) {
        print('Timeout error: ${e.message}');
      }
      _showErrorDialog('Connection Error', 'Unable to connect to the server: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 18, 152),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: const Duration(seconds: 3),
        elevation: 6,
      ),
    );
  }

  void _handleSocialLogin(String platform) {
    if (platform == "Google") {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$platform login coming soon'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(seconds: 3),
          elevation: 6,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final primaryColor = const Color.fromARGB(255, 0, 18, 152);
    final secondaryColor = const Color.fromARGB(255, 14, 105, 213);

    final headerHeight = size.height * 0.28;
    final contentPadding = EdgeInsets.symmetric(
      horizontal: size.width < 360 ? 16.0 : 20.0,
      vertical: 8.0,
    );
    final logoSize = size.width < 360 ? 100.0 : 120.0;
    final titleFontSize = size.width < 360 ? 28.0 : 32.0;
    final buttonHeight = size.width < 360 ? 45.0 : 50.0;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
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
                          primaryColor.withOpacity(0.7),
                          primaryColor.withOpacity(0.0),
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
          Positioned(
            bottom: -size.width * 0.6,
            left: -size.width * 0.3,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_animationController.value * 0.2,
                  child: Container(
                    width: size.width * 0.9,
                    height: size.width * 0.9,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          secondaryColor.withOpacity(0.7),
                          secondaryColor.withOpacity(0.0),
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
              constraints: BoxConstraints(
                minHeight: size.height - padding.top,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
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
                                ? [primaryColor, secondaryColor.withOpacity(0.8)]
                                : [secondaryColor, const Color(0xFF4285F4)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  math.sin(_animationController.value * math.pi * 2) * 5,
                                ),
                                child: child,
                              );
                            },
                            child: Hero(
                              tag: 'app_logo',
                              child: Container(
                                width: logoSize,
                                height: logoSize,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/images/white.png',
                                  width: logoSize,
                                  height: logoSize,
                                ),
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
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [primaryColor, secondaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'WELCOME!',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: size.height * 0.00),
                          Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.015),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: !_isEmailValid
                                    ? Colors.red
                                    : (isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.05)),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: TextField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  onChanged: (value) {
                                    if (!_isEmailValid) {
                                      setState(() {
                                        _isEmailValid = true;
                                      });
                                    }
                                  },
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle: TextStyle(
                                      color: isDarkMode ? Colors.white60 : Colors.black54,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: size.width < 360 ? 14 : 16,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.only(left: 16, right: 8),
                                      child: Icon(
                                        Icons.email_outlined,
                                        color: isDarkMode
                                            ? primaryColor.withOpacity(0.9)
                                            : primaryColor,
                                        size: 22,
                                      ),
                                    ),
                                    suffixIcon: !_isEmailValid
                                        ? Container(
                                            margin: const EdgeInsets.only(right: 16),
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 22,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!_isEmailValid)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8),
                              child: Text(
                                'Please enter a valid email',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          SizedBox(height: size.height * 0.008),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: !_isPasswordValid
                                    ? Colors.red
                                    : (isDarkMode
                                        ? Colors.white.withOpacity(0.1)
                                        : Colors.black.withOpacity(0.05)),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  onChanged: (value) {
                                    if (!_isPasswordValid) {
                                      setState(() {
                                        _isPasswordValid = true;
                                      });
                                    }
                                  },
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                      color: isDarkMode ? Colors.white60 : Colors.black54,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: size.width < 360 ? 14 : 16,
                                    ),
                                    border: InputBorder.none,
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.only(left: 16, right: 8),
                                      child: Icon(
                                        Icons.lock_outline,
                                        color: isDarkMode
                                            ? primaryColor.withOpacity(0.9)
                                            : primaryColor,
                                        size: 22,
                                      ),
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!_isPasswordValid)
                                          Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            child: const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                              size: 22,
                                            ),
                                          ),
                                        Container(
                                          margin: const EdgeInsets.only(right: 16),
                                          child: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: isDarkMode ? Colors.white60 : Colors.grey,
                                              size: 22,
                                            ),
                                            onPressed: () =>
                                                setState(() => _obscurePassword = !_obscurePassword),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (!_isPasswordValid)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 8),
                              child: Text(
                                'Password must be at least 6 characters',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Transform.scale(
                                        scale: 0.9,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (value) =>
                                              setState(() => _rememberMe = value ?? false),
                                          fillColor: MaterialStateProperty.resolveWith(
                                            (states) => states.contains(MaterialState.selected)
                                                ? primaryColor
                                                : (isDarkMode
                                                    ? Colors.white38
                                                    : Colors.grey.shade300),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : const Color.fromARGB(221, 0, 0, 0),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Forgot password feature coming soon'),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16)),
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                      duration: const Duration(seconds: 3),
                                      elevation: 6,
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Container(
                            height: buttonHeight,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -4,
                                ),
                              ],
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _isLoading
                                    ? [
                                        primaryColor.withOpacity(0.7),
                                        secondaryColor.withOpacity(0.7),
                                      ]
                                    : [primaryColor, secondaryColor],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: size.width < 360 ? 16 : 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: size.width < 360 ? 18 : 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.008),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'New user?',
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/account-type'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1.5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          isDarkMode ? Colors.transparent : Colors.white,
                                          isDarkMode ? Colors.white38 : Colors.grey[400]!,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.white.withOpacity(0.05)
                                          : Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.1)
                                            : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white70 : Colors.black54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1.5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          isDarkMode ? Colors.white38 : Colors.grey[400]!,
                                          isDarkMode ? Colors.transparent : Colors.white,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 4,
                              bottom: math.max(12.0, padding.bottom),
                            ),
                            child: Center(
                              child: Container(
                                width: 350.0,
                                height: 45.0,
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () => _handleSocialLogin('Google'),
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/google.png',
                                        width: 24.0,
                                        height: 24.0,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

  Widget _socialButton(
    String iconPath,
    VoidCallback onPressed,
    bool isDarkMode,
    Color primaryColor,
    int index,
    Size size, [
    double? customSize,
  ]) {
    final buttonSize = customSize ?? (size.width < 360 ? 48.0 : 56.0);
    final iconSize = buttonSize * 0.5;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = 0.2 + (index * 0.1);
        final opacity = _animationController.value > delay
            ? ((_animationController.value - delay) / (1 - delay)).clamp(0.0, 1.0)
            : 0.0;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          padding: EdgeInsets.all(buttonSize * 0.25),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
            border: Border.all(
              color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Image.asset(
            iconPath,
            height: iconSize,
            width: iconSize,
          ),
        ),
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
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}