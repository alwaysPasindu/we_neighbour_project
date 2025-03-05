import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:we_neighbour/features/services/service_detailsPage.dart';
import '../widgets/header_widget.dart';
import '../widgets/feature_grid.dart';
import '../widgets/bottom_navigation.dart';
import '../constants/colors.dart';
import '../main.dart';
import '../models/service.dart'; // Updated to use your Service model
import '../utils/auth_utils.dart';

class HomeScreen extends StatefulWidget {
  final UserType userType;

  const HomeScreen({super.key, required this.userType});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Service> _featuredServices = [];
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;
  String? _token;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    await _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _token = prefs.getString('token');
    });
    if (_token != null) {
      await _loadServices();
    }
  }

  Future<void> _loadServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/services?latitude=6.9271&longitude=79.8612'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Increased timeout to 15 seconds

      print('HomeScreen load services response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = jsonDecode(response.body) as List<dynamic>;
        final services = servicesJson.map((json) => Service.fromJson(json as Map<String, dynamic>)).toList();
        setState(() {
          _featuredServices = services;
        });
        await prefs.setString('services', jsonEncode(services.map((s) => s.toJson()).toList()));
      } else {
        throw Exception('Failed to load services: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException catch (e) {
      print('Timeout loading services in HomeScreen: $e');
      final String? servicesJson = prefs.getString('services');
      if (servicesJson != null) {
        final List<dynamic> decodedServices = jsonDecode(servicesJson);
        setState(() {
          _featuredServices = decodedServices.map((service) => Service.fromJson(service as Map<String, dynamic>)).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timeout loading services. Showing cached data.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timeout loading services. No cached data available.')),
        );
      }
    } catch (e) {
      print('Error loading services in HomeScreen: $e');
      final String? servicesJson = prefs.getString('services');
      if (servicesJson != null) {
        final List<dynamic> decodedServices = jsonDecode(servicesJson);
        setState(() {
          _featuredServices = decodedServices.map((service) => Service.fromJson(service as Map<String, dynamic>)).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e. Showing cached data if available.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e. No cached data available.')),
        );
      }
    }
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_featuredServices.isEmpty) return;
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

  void _onTabTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) { // Chat tab
      Navigator.pushNamed(context, '/chat', arguments: widget.userType);
    } else if (index == 2) { // Resource tab
      Navigator.pushNamed(context, '/resource');
    } else if (index == 3) { // Service tab
      Navigator.pushNamed(context, '/service', arguments: widget.userType);
    } else if (index == 4) { // Profile tab
      final token = prefs.getString('token');

      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final userType = await AuthUtils.getUserType();
      Navigator.pushNamed(context, '/profile', arguments: userType);
    }
  }

  void _onServiceTap(Service service) async {
    final currentUserId = prefs.getString('userId') ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailsPage(
          service: service,
          isOwnService: service.serviceProviderId == currentUserId,
          userType: widget.userType,
        ),
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
                            return Card(
                              elevation: 8,
                              shadowColor: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              color: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
                              child: InkWell(
                                onTap: () => _onServiceTap(service),
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                                                  service.serviceProviderName,
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
                                                const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    service.location.address,
                                                    style: TextStyle(
                                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
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
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No featured services available',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
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