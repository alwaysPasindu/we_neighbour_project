import 'package:flutter/material.dart';
import '../widgets/grid_icon.dart';
import '../widgets/service_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        elevation: 0,
        title: Row(
          children: [
            Text('Good Morning, John...!'),
            Spacer(),
            Icon(Icons.notifications, color: Colors.white),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Greeting Card
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.blue[700],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WE NEIGHBOUR',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Icon(Icons.people_alt, color: Colors.white, size: 50),
                    ],
                  ),
                  Icon(Icons.apartment, color: Colors.white, size: 80),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Grid Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  GridIcon(title: 'AMENITIES BOOKING', icon: Icons.check_circle, color: Colors.green),
                  GridIcon(title: 'VISITOR MANAGEMENT', icon: Icons.person, color: Colors.orange),
                  GridIcon(title: 'EVENT CALENDAR', icon: Icons.calendar_today, color: Colors.red),
                  GridIcon(title: 'Apartment MAINTENANCE', icon: Icons.settings, color: Colors.blue),
                  GridIcon(title: 'BILLS', icon: Icons.receipt_long, color: Colors.amber),
                  GridIcon(title: 'Chats', icon: Icons.chat, color: Colors.purple),
                ],
              ),
            ),

            // Horizontal Cards
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ServiceCard(
                        text: 'High-quality painting services for a fresh new look.', icon: Icons.format_paint),
                    ServiceCard(
                        text: 'Expert plumbing services for all your needs.', icon: Icons.plumbing),
                    ServiceCard(
                        text: 'Professional carpentry work for repairs and improvements.', icon: Icons.handyman),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}
