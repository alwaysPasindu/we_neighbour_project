import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: screenHeight * 0.1), // Reserve space for icons
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Section with Logo and Greeting
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.03,
                      horizontal: screenWidth * 0.05,
                    ),
                    color: AppTheme.accentColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo and Greeting
                        Row(
                          children: [
                            // Logo
                            Image.asset(
                              'assets/images/logo.jpeg', // Replace with your logo path
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.1,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good Morning, John...!',
                                  style: AppTheme.titleStyle.copyWith(
                                    color: Colors.white,
                                    fontSize: 18, // Increased size
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      width: 10, // Bigger red dot
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.notifications, color: Colors.white),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Bell icon
                        const Icon(Icons.notifications, color: Colors.white),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Feature Grid Section
                  _buildFeatureGrid(screenHeight),

                  const SizedBox(height: 20),

                  // Service Cards Section
                  Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.all(16),
                    child: _buildServiceCard(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Icons Section
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: _buildIconSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(double screenHeight) {
    final features = [
      {'image': 'assets/images/amenities.webp', 'text': 'Amenities Booking'},
      {'image': 'assets/images/visitor.svg', 'text': 'Visitor Management'},
      {'image': 'assets/images/calendar.avif', 'text': 'Event Calendar'},
      {'image': 'assets/images/maintain.jpg', 'text': 'Apartment Maintenance'},
      {'image': 'assets/images/bill.webp', 'text': 'Bills'},
      {'image': 'assets/images/chats.png', 'text': 'Chats'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final isSvg = features[index]['image']!.endsWith('.svg');
          return Column(
            children: [
              isSvg
                  ? SvgPicture.asset(
                      features[index]['image']!,
                      width: screenHeight * 0.08,
                      height: screenHeight * 0.08,
                    )
                  : Image.asset(
                      features[index]['image']!,
                      width: screenHeight * 0.08,
                      height: screenHeight * 0.08,
                    ),
              const SizedBox(height: 8),
              Text(
                features[index]['text']!,
                style: AppTheme.bodyStyle.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildServiceCard() {
    final services = [
      {
        'image': 'assets/images/painter.jpg',
        'description': 'High-quality painting services for a fresh new look.',
      },
      {
        'image': 'assets/images/plumber.jpg',
        'description': 'Expert plumbing services for all your needs.',
      },
      {
        'image': 'assets/images/carpenter.jpg',
        'description': 'Professional carpentry work for repairs and improvements.',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: services.map((service) {
        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: 120,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    service['image']!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  service['description']!,
                  style: AppTheme.bodyStyle.copyWith(fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        Icon(Icons.home, color: Colors.black, size: 30),
        Icon(Icons.chat, color: Colors.black, size: 30),
        Icon(Icons.group, color: Colors.black, size: 30),
        Icon(Icons.settings, color: Colors.black, size: 30),
        Icon(Icons.person, color: Colors.black, size: 30),
      ],
    );
  }
}
