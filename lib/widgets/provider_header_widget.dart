import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/features/notifications&alets/provider_notification_page.dart';

class HeaderWidget extends StatefulWidget {
  const HeaderWidget({super.key});

  @override
  State<HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  String _companyName = 'Company';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    final name = prefs.getString('userName') ?? 'Company';
    if (mounted) {
      setState(() {
        _companyName = name.split(' ').map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Color(0xFF0E69D5),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 90),
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
                    : Text('Hello, $_companyName...!', style: AppTextStyles.greeting),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationPage())),
              child: const Icon(Icons.notifications, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}