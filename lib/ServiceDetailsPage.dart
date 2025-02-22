import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/service.dart';
import '../providers/theme_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          service.title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF004CFF),
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 200,
              child: CarouselSlider(
                slideTransform: const CubeTransform(),
                slideIndicator: CircularSlideIndicator(
                  padding: const EdgeInsets.only(bottom: 32),
                  indicatorBackgroundColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  currentIndicatorColor: isDarkMode ? Colors.white : const Color(0xFF004CFF),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF202020),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provided by: ${service.companyName}',
                    style: TextStyle(
                      fontSize: 14,
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
}