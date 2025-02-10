import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications',
      theme: ThemeData(
        primaryColor: const Color(0xFF1A2B4A),
        scaffoldBackgroundColor: const Color(0xFF1A2B4A),
      ),
      home: const NotificationsScreen(),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Spacer to push buttons to middle
            const Spacer(),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  NotificationButton(
                    title: 'Management',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ManagementNotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  NotificationButton(
                    title: 'Community',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CommunityNotificationsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Spacer to push logo to bottom
            const Spacer(),

            // Logo
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Column(
                children: const [
                  Text(
                    'WE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'NEIBHOUR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManagementNotificationsScreen extends StatelessWidget {
  const ManagementNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Logo
            const Text(
              'WE\nNEIGHBOUR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Management\nNotifications',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Notifications List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: const [
                  NotificationCard(
                    icon: "🔧",
                    message:
                        "Notice: Scheduled electrical maintenance on floors 2-5 on 08.10.2024. Expect power interruptions from 10 AM to 3 PM.",
                  ),
                  NotificationCard(
                    icon: "📝",
                    message:
                        "Please check the Noticeboard for an important update regarding parking regulations.",
                  ),
                  NotificationCard(
                    icon: "📊",
                    message:
                        "Your monthly utility bill is ready for review in the Bills section. Due date: 02.10.2024",
                  ),
                  NotificationCard(
                    icon: "✔️",
                    message:
                        "Your maintenance request has been completed. Please provide feedback to help us improve our services.",
                  ),
                  NotificationCard(
                    icon: "👓",
                    message:
                        "Found: A pair of glasses in the common area. Visit the management office to claim.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityNotificationsScreen extends StatelessWidget {
  const CommunityNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Logo
            const Text(
              'WE\nNEIGHBOUR',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Community\nNotifications',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Notifications List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: const [
                  NotificationCard(
                    icon: "🎉",
                    message:
                        "Community BBQ this weekend! Join us on Saturday at 4 PM in the garden area.",
                  ),
                  NotificationCard(
                    icon: "🏃",
                    message:
                        "New yoga classes starting next week. Register at the community center.",
                  ),
                  NotificationCard(
                    icon: "📢",
                    message:
                        "Reminder: Monthly community meeting this Thursday at 7 PM.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const NotificationButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2D69DD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String icon;
  final String message;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
