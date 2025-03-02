import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../models/service.dart';
import '../../../providers/theme_provider.dart';

class ServiceDetailsPage extends StatelessWidget {
  final Service service;

  const ServiceDetailsPage({
    Key? key,
    required this.service,
  }) : super(key: key);

  Widget _buildServiceImage(String imagePath) {
    return FutureBuilder<bool>(
      future: File(imagePath).exists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == true) {
            return Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return _buildPlaceholderImage(context);
              },
            );
          } else {
            print('Image file does not exist: $imagePath');
            return _buildPlaceholderImage(context);
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return Container(
      color: isDarkMode ? const Color(0xFF404040) : const Color(0xFFD7D7D7),
      child: Icon(
        Icons.image_not_supported,
        size: 40,
        color: isDarkMode ? Colors.grey[400] : const Color(0xFF202020),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String title, String value) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return Card(
      color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDarkMode ? const Color(0xFF004CFF) : const Color(0xFF0C78F8),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF202020),
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.4,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF004CFF),
            flexibleSpace: FlexibleSpaceBar(
              background: CarouselSlider(
                slideTransform: const CubeTransform(),
                slideIndicator: CircularSlideIndicator(
                  padding: const EdgeInsets.only(bottom: 32),
                  indicatorBackgroundColor: Colors.black.withOpacity(0.2),
                  currentIndicatorColor: Colors.white,
                ),
                unlimitedMode: true,
                children: service.imagePaths.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return _buildServiceImage(imagePath);
                    },
                  );
                }).toList(),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service.title,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : const Color(0xFF202020),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF004CFF) : const Color(0xFF0C78F8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '4.5',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF2C2C2C) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service.description,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: isDarkMode ? Colors.grey[300] : const Color(0xFF1E1E1E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Service Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : const Color(0xFF202020),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          context,
                          Icons.business,
                          'Service Provider',
                          service.companyName,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          Icons.location_on,
                          'Location',
                          service.location.isEmpty ? 'New York, USA' : service.location,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          Icons.access_time,
                          'Available Hours',
                          service.availableHours.isEmpty ? '9:00 AM - 6:00 PM' : service.availableHours,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add booking functionality
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDarkMode ? const Color(0xFF004CFF) : const Color(0xFF0C78F8),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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