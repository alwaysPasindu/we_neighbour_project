import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/header_widget.dart';
import '../widgets/feature_grid.dart';
import '../widgets/bottom_navigation.dart';
import '../constants/colors.dart';
import '../main.dart';
import '../models/service.dart';
import '../features/services/service_detailsPage.dart';
import '../features/chat/chat_list_page.dart'; // Import ChatListPage

class HomeScreen extends StatefulWidget {
  final UserType userType;
  const HomeScreen({Key? key, required this.userType}) : super(key: key);
  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List _featuredServices = [];
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

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

  Future _loadServices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? servicesJson = prefs.getString('services');
    if (servicesJson != null) {
      final List decodedServices = jsonDecode(servicesJson);
      setState(() {
        _featuredServices = decodedServices
            .map((service) => Service.fromJson(service))
            .toList();
      });
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _featuredServices.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // if (index == 1) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => ChatListPage(),
    //     ),
    //   );
    // }

    if (index == 2) {
      Navigator.pushNamed(context, '/resource');
    }
    if (index == 3) {
      Navigator.pushNamed(
        context,
        '/service',
        arguments: widget.userType,
      );
    }
    if (index == 4) {
      Navigator.pushNamed(
        context,
        '/profile',
        arguments: widget.userType,
      );
    }
  }

  void _onServiceTap(Service service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailsPage(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : const Color.fromARGB(255, 255, 254, 254),
      body: Column(
        children: [
          HeaderWidget(isDarkMode: isDarkMode),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadServices,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeatureGrid(isDarkMode: isDarkMode),
                    const SizedBox(height: 24),
                    if (_featuredServices.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Featured Services',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: size.height * 0.35,
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
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.only(
                                right: 16,
                                left: index == 0 ? 16 : 0,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Card(
                                elevation: 8,
                                shadowColor: isDarkMode
                                    ? Colors.black.withOpacity(0.4)
                                    : Colors.grey.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
                                child: InkWell(
                                  onTap: () => _onServiceTap(service),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                        child: Stack(
                                          children: [
                                            Hero(
                                              tag: 'service_image_${service.id}',
                                              child: Image.file(
                                                File(service.imagePaths.first),
                                                height: size.height * 0.2,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned.fill(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black.withOpacity(0.8),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 12,
                                              left: 12,
                                              right: 12,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    service.title,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    service.companyName,
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.9),
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.description,
                                                style: TextStyle(
                                                  color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const Spacer(),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on,
                                                    size: 16,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    service.location,
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  const Icon(
                                                    Icons.access_time_rounded,
                                                    size: 16,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    service.availableHours,
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
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
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _featuredServices.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? AppColors.primary
                                  : (isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary).withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        userType: widget.userType,
        isDarkMode: isDarkMode,
      ),
    );
  }
}
