import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'models/service.dart';
import '../widgets/header_widget.dart';
import '../providers/theme_provider.dart';
import 'ServiceDetailsPage.dart';

// Advertisement class remains the same
class Advertisement {
  final String title;
  final String description;
  final String imageUrl;
  final String companyName;

  Advertisement({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.companyName,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Service> _featuredServices = [];
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  Timer? _timer;

  // Advertisement list remains the same
  final List<Advertisement> generalAds = [
    Advertisement(
      title: 'Special Discount',
      description: '20% off on all services this week',
      imageUrl: 'https://thumbs.dreamstime.com/z/discount-stamp-seal-illustration-design-over-white-background-32214259.jpg?ct=jpeg',
      companyName: 'ABC Company',
    ),
    Advertisement(
      title: 'New Service Launch',
      description: 'Try our new premium cleaning service',
      imageUrl: 'https://cdn.pixabay.com/photo/2017/03/27/13/54/bread-2178874_1280.jpg',
      companyName: 'XYZ Cleaners',
    ),
    Advertisement(
      title: 'Referral Program',
      description: 'Refer a friend and get 50 off your next service',
      imageUrl: 'https://media.istockphoto.com/id/1432158212/photo/referral-program.jpg?s=1024x1024&w=is&k=20&c=1NvpQbDz5c2vTciRWVIc_eKGWFkb1VRpku14fKh5L4Q=',
      companyName: 'We Neighbour',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Other methods remain the same
  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _featuredServices.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }

  Future<void> _loadServices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? servicesJson = prefs.getString('services');
    if (servicesJson != null) {
      final List<dynamic> decodedServices = jsonDecode(servicesJson);
      setState(() {
        _featuredServices = decodedServices.map((service) => Service.fromJson(service)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme mode
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderWidget(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _featuredServices.length,
                      onPageChanged: (int page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        final service = _featuredServices[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailsPage(service: service),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Card(
                              color: isDarkMode ? Colors.grey[850] : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Image.file(
                                      File(service.imagePaths.first),
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          service.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          service.description,
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advertisements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: generalAds.length,
                    itemBuilder: (context, index) {
                      final ad = generalAds[index];
                      return Card(
                        color: isDarkMode ? const Color.fromARGB(255, 67, 67, 67) : Colors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                ad.imageUrl,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ad.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ad.description,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ad.companyName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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