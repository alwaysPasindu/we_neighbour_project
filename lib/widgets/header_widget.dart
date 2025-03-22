import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/features/notifications&alets/notifications_screen.dart';
import 'package:we_neighbour/features/notifications&alets/safety_alerts.dart';

class HeaderWidget extends StatefulWidget {
  final bool isDarkMode;

  const HeaderWidget({super.key, required this.isDarkMode});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  String _userName = 'User';
  String _userStatus = 'approved';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _getFirstName(String fullName) {
    final nameParts = fullName.trim().split(' ');
    if (nameParts.isEmpty) return 'User';
    String firstName = nameParts[0];
    if (firstName.isEmpty) return 'User';
    return firstName[0].toUpperCase() + firstName.substring(1).toLowerCase();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    final fullName = prefs.getString('userName') ?? 'User';
    final status = prefs.getString('userStatus') ?? 'approved';

    if (mounted) {
      setState(() {
        _userName = _getFirstName(fullName);
        _userStatus = status;
        _isLoading = false;
      });
    }

    if (prefs.getString('userRole') == 'resident' && status == 'pending' && mounted) {
      Navigator.pushReplacementNamed(context, '/pending-approval');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color.fromARGB(255, 0, 18, 152) : const Color.fromARGB(255, 14, 105, 213),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            color: widget.isDarkMode ? const Color.fromARGB(255, 0, 18, 152) : const Color.fromARGB(255, 14, 105, 213),
            height: MediaQuery.of(context).padding.top,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 90,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 0),
                    _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hello, \n$_userName !', style: AppTextStyles.greeting),
                              if (_userStatus == 'pending')
                                const Text(
                                  'Awaiting Approval',
                                  style: TextStyle(fontSize: 14, color: Colors.yellowAccent, fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SafetyAlertsScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.warning_amber_rounded, color: Color.fromARGB(255, 249, 56, 56), size: 30),
                      ),
                    ),
                    const SizedBox(width: 1),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.notifications, color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}