import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:we_neighbour/constants/colors.dart';
import '../widgets/provider_header_widget.dart';
import '../../providers/theme_provider.dart';
import '../features/services/service_detailsPage.dart';
import '../widgets/provider_bottom_navigation.dart';
import '../main.dart';
import '../models/service.dart';

class Advertisement {
  final String title;
  final String description;
  final String imageUrl;
  final String companyName;

  Advertisement({required this.title, required this.description, required this.imageUrl, required this.companyName});
}

class ProviderHomePage extends StatefulWidget {
  const ProviderHomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ProviderHomePage> {
  List<Service> _featuredServices = [];
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;
  Timer? _timer;
  int _currentIndex = 0;
  String? _token;
  late SharedPreferences prefs;
  bool _isLoading = true;

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
    await _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/service/get-service?latitude=6.9271&longitude=79.8612'),
        headers: {
          'x-auth-token': _token!,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('ProviderHomePage load services response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = jsonDecode(response.body);
        final services = servicesJson.map((json) => Service.fromJson(json)).toList();
        setState(() {
          _featuredServices = services;
        });
        await prefs.setString('services', jsonEncode(services.map((s) => s.toJson()).toList()));
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to load services: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error loading services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading services: $e')));
      }
      final String? servicesJson = prefs.getString('services');
      if (servicesJson != null) {
        final List<dynamic> decodedServices = jsonDecode(servicesJson);
        setState(() {
          _featuredServices = decodedServices.map((service) => Service.fromJson(service)).toList();
        });
      }
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
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);

    if (index == 1) {
      Navigator.pushNamed(context, '/service', arguments: UserType.serviceProvider);
    } else if (index == 2) {
      Navigator.pushNamed(context, '/provider-profile');
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
          userType: UserType.serviceProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadServices,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _featuredServices.length,
                        onPageChanged: (int page) => setState(() => _currentPage = page),
                        itemBuilder: (context, index) {
                          final service = _featuredServices[index];
                          return GestureDetector(
                            onTap: () => _onServiceTap(service),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Card(
                                color: isDarkMode ? Colors.grey[850] : Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.file(
                                        File(service.imagePaths.first),
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 120,
                                          color: Colors.grey,
                                          child: const Icon(Icons.image_not_supported, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service.title,
                                            style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            service.description,
                                            style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12),
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
                                : (isDarkMode ? Colors.grey[400] : Colors.grey[600])?.withOpacity(0.3),
                          ),
                        ),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
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
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                child: Image.network(
                                  ad.imageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 150,
                                    color: Colors.grey,
                                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ad.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
                                    const SizedBox(height: 8),
                                    Text(ad.description, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600])),
                                    const SizedBox(height: 8),
                                    Text(ad.companyName, style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
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
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        userType: UserType.serviceProvider,
        isDarkMode: isDarkMode,
      ),
    );
  }
}