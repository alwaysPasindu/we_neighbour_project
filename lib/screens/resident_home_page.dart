import 'package:flutter/material.dart';
import '../widgets/feature_item.dart';
import '../widgets/service_card.dart';

class ResidentHomePage extends StatelessWidget {
  const ResidentHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildFeatureGrid(),
                  const SizedBox(height: 30),
                  _buildServiceCards(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2E88FF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Text(
                    'WE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'NEIGHBOUR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Good Morning, John...!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          _buildNotificationBell(),
        ],
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Stack(
      children: [
        const Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 28,
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: const [
        FeatureItem(
          icon: Icons.calendar_today,
          label: 'AMENITIES BOOKING',
          color: Colors.green,
        ),
        FeatureItem(
          icon: Icons.people,
          label: 'VISITOR MANAGEMENT',
          color: Colors.blue,
        ),
        FeatureItem(
          icon: Icons.event,
          label: 'EVENT CALENDAR',
          color: Colors.orange,
        ),
        FeatureItem(
          icon: Icons.build,
          label: 'Apartment MAINTENANCE',
          color: Colors.purple,
        ),
        FeatureItem(
          icon: Icons.receipt,
          label: 'BILLS',
          color: Colors.red,
        ),
        FeatureItem(
          icon: Icons.chat_bubble,
          label: 'Chats',
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildServiceCards() {
    return Column(
      children: const [
        ServiceCard(
          title: 'High-quality painting services',
          subtitle: 'for a fresh new look.',
          company: 'ABC Company',
          iconData: Icons.format_paint,
        ),
        SizedBox(height: 15),
        ServiceCard(
          title: 'Expert plumbing services',
          subtitle: 'for all your needs.',
          company: 'ABC Company',
          iconData: Icons.plumbing,
        ),
        SizedBox(height: 15),
        ServiceCard(
          title: 'Professional carpentry work',
          subtitle: 'for repairs and improvements.',
          company: 'ABC Company',
          iconData: Icons.handyman,
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Call'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: 0,
      selectedItemColor: Color(0xFF2E88FF),
    );
  }
}
