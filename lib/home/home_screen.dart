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
import '../models/service.dart';
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
  bool _isLoading = true;

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
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    _token = prefs.getString('token');
    if (_token == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    final userStatus = prefs.getString('userStatus') ?? 'approved';
    if (userStatus == 'pending' && widget.userType == UserType.resident) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/pending-approval');
      }
      return;
    }

    await _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/services?latitude=6.9271&longitude=79.8612'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('HomeScreen load services response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = jsonDecode(response.body);
        final services = servicesJson.map((json) => Service.fromJson(json)).toList();
        setState(() {
          _featuredServices = services;
        });
        await prefs.setString('services', jsonEncode(services.map((s) => s.toJson()).toList()));
      } else {
        throw Exception('Failed to load services: ${response.body}');
      }
    } on TimeoutException catch (e) {
      print('Timeout loading services: $e');
      _loadCachedServices('Timeout loading services. Showing cached data.');
    } catch (e) {
      print('Error loading services: $e');
      _loadCachedServices('Error loading services: $e. Showing cached data if available.');
    }
  }

  void _loadCachedServices(String message) {
    final String? servicesJson = prefs.getString('services');
    if (servicesJson != null) {
      final List<dynamic> decodedServices = jsonDecode(servicesJson);
      setState(() {
        _featuredServices = decodedServices.map((service) => Service.fromJson(service)).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cached services available.')),
      );
    }
  }

  Future<void> _signOut() async {
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
    setState(() => _currentIndex = index);

    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/chat', arguments: widget.userType);
        break;
      case 2:
        Navigator.pushNamed(context, '/resource');
        break;
      case 3:
        Navigator.pushNamed(context, '/service', arguments: widget.userType);
        break;
      case 4:
        if (_token == null) {
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
        final userType = await AuthUtils.getUserType();
        Navigator.pushNamed(context, '/profile', arguments: userType);
        break;
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

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : const Color.fromARGB(255, 255, 254, 254),
      body: Column(
        children: [
          HeaderWidget(isDarkMode: isDarkMode),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadServices(); // Refresh services only
              },
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
                          onPageChanged: (int page) => setState(() => _currentPage = page),
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
                                              errorBuilder: (_, __, ___) => Container(
                                                height: size.height * 0.2,
                                                color: Colors.grey,
                                                child: const Icon(Icons.image_not_supported, color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
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
                                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  service.serviceProviderName,
                                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
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
                          style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
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