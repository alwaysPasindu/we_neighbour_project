import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class ShareAppScreen extends StatelessWidget {
  ShareAppScreen({super.key});

  final Logger logger = Logger();
  static const String appLink = 'https://weneighbour.com/app';
  static const String shareMessage =
      'Check out We-Neighbour, the ultimate community management app for apartment residents! Download now: $appLink';
  static const String shareSubject = 'Join your community on We-Neighbour!';

  void _shareApp(BuildContext context, {String? platform}) {
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Capture ScaffoldMessenger early

    logger.d('Sharing app${platform != null ? " via $platform" : ""}');
    try {
      Share.share(
        shareMessage,
        subject: shareSubject,
        // Add platform-specific handling if needed in the future
      );
    } catch (e) {
      logger.e('Error sharing app: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to share: $e')),
      );
    }
  }

  void _copyLink(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context); // Capture ScaffoldMessenger early

    logger.d('Copying app link to clipboard');
    Clipboard.setData(const ClipboardData(text: appLink)).then((_) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }).catchError((e) {
      logger.e('Error copying link: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to copy link: $e')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> platforms = [
      {
        'name': 'WhatsApp',
        'icon': Icons.chat,
        'color': const Color(0xFF25D366),
      },
      {
        'name': 'Facebook',
        'icon': Icons.facebook,
        'color': const Color(0xFF1877F2),
      },
      {
        'name': 'Twitter',
        'icon': Icons.share,
        'color': const Color(0xFF1DA1F2),
      },
      {
        'name': 'Email',
        'icon': Icons.email,
        'color': const Color(0xFF9E9E9E),
      },
      {
        'name': 'SMS',
        'icon': Icons.sms,
        'color': const Color(0xFF4CAF50),
      },
      {
        'name': 'Copy Link',
        'icon': Icons.link,
        'color': const Color(0xFF607D8B),
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Share App',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1), // Line 115:64
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.share,
                size: 60,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Invite Your Neighbors',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Help grow your community by inviting your neighbors to join We-Neighbour!',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: platforms.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      final platformName = platforms[index]['name'];
                      if (platformName == 'Copy Link') {
                        _copyLink(context);
                      } else {
                        _shareApp(context, platform: platformName);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: platforms[index]['color'].withValues(alpha: 0.1), // Line 150:58
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            platforms[index]['icon'],
                            color: platforms[index]['color'],
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          platforms[index]['name'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _shareApp(context),
              icon: const Icon(Icons.share, color: Colors.white),
              label: const Text(
                'Share Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}