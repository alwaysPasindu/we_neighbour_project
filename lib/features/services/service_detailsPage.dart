import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/models/service.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'dart:io';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsPage extends StatefulWidget {
  final Service service;
  final bool isOwnService;
  final UserType userType;

  const ServiceDetailsPage({
    Key? key,
    required this.service,
    required this.isOwnService,
    required this.userType,
  }) : super(key: key);

  @override
  State<ServiceDetailsPage> createState() => _ServiceDetailsPageState();
}

class _ServiceDetailsPageState extends State<ServiceDetailsPage> {
  final CarouselSliderController _sliderController = CarouselSliderController();
  int _currentImageIndex = 0;
  List<dynamic> _reviews = []; // Store reviews fetched from the backend
  String? _token;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchReviews(); // Load user data and fetch reviews on init
  }

  Future<void> _loadUserDataAndFetchReviews() async {
    await _loadUserData();
    await _fetchReviews(); // Fetch reviews after loading token
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  Future<void> _fetchReviews() async {
    if (_token == null) return;

    setState(() {
      _isLoadingReviews = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/services/${widget.service.id}'), // Fetch specific service by ID
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final serviceData = jsonDecode(response.body);
        setState(() {
          _reviews = serviceData['reviews'] ?? [];
        });
      } else {
        throw Exception('Failed to fetch reviews: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching reviews: $e')));
    } finally {
      setState(() {
        _isLoadingReviews = false;
      });
    }
  }

  void _addReview() {
    final TextEditingController commentController = TextEditingController();
    int rating = 5;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: rating,
                    items: List.generate(5, (index) => index + 1)
                        .map((value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text('$value Stars'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        rating = value!;
                      });
                    },
                  ),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(labelText: 'Comment'),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('token');
                    final userId = prefs.getString('userId') ?? '';
                    final userRole = prefs.getString('userRole')?.toLowerCase() ?? 'resident';

                    if (token == null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to add a review')));
                      return;
                    }

                    try {
                      final response = await http.post(
                        Uri.parse('$baseUrl/api/services/${widget.service.id}/reviews'),
                        headers: {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          'rating': rating,
                          'comment': commentController.text,
                          'role': userRole, // Send the user's role (e.g., 'serviceprovider', 'resident', 'manager')
                        }),
                      );

                      print('Add review response: ${response.statusCode} - ${response.body}');

                      if (response.statusCode == 201) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review added successfully')));
                        await _fetchReviews(); // Auto-refresh reviews after adding
                        // Force a full refresh to handle user switch
                        setState(() {});
                      } else if (response.statusCode == 401) {
                        try {
                          final errorData = jsonDecode(response.body);
                          throw Exception(errorData['message'] ?? 'Unauthorized: Please check your role or token');
                        } catch (e) {
                          throw Exception('Unauthorized: Unable to add review - ${response.statusCode} - ${response.body}');
                        }
                      } else {
                        try {
                          final errorData = jsonDecode(response.body);
                          throw Exception('Failed to add review: ${errorData['message'] ?? response.statusCode}');
                        } catch (e) {
                          throw Exception('Failed to add review: ${response.statusCode} - ${response.body}');
                        }
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Google Maps')));
    }
  }

  double _calculateAverageRating() {
    if (_reviews.isEmpty) return 0.0;
    final totalRating = _reviews.fold(0.0, (sum, review) => sum + (review['rating'] as num).toDouble());
    return totalRating / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final size = MediaQuery.of(context).size;
    final averageRating = _calculateAverageRating();

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.4,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black54 : Colors.white54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  CarouselSlider.builder(
                    unlimitedMode: true,
                    controller: _sliderController,
                    slideBuilder: (index) {
                      return Hero(
                        tag: 'service_image_${widget.service.id}_$index',
                        child: Image.file(
                          File(widget.service.imagePaths[index]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                    slideTransform: const DefaultTransform(),
                    itemCount: widget.service.imagePaths.length,
                    initialPage: 0,
                    onSlideChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.service.imagePaths.length,
                        (index) => Container(
                          width: _currentImageIndex == index ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentImageIndex == index ? AppColors.primary : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            isDarkMode ? Colors.black87 : Colors.black54,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.service.serviceProviderName,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!widget.isOwnService)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.yellow[700], size: 20),
                              const SizedBox(width: 4),
                              Text(
                                averageRating.toStringAsFixed(1), // Display dynamic average rating
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.service.description,
                    style: TextStyle(fontSize: 16, height: 1.5, color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Service Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    icon: Icons.access_time,
                    title: 'Available Hours',
                    value: widget.service.availableHours,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _openGoogleMaps(widget.service.location.coordinates[1], widget.service.location.coordinates[0]),
                    child: _buildInfoItem(
                      icon: Icons.location_on,
                      title: 'Location',
                      value: widget.service.location.address,
                      isDarkMode: isDarkMode,
                    ),
                  ),
                  if (!widget.isOwnService) ...[
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking functionality coming soon!')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 16),
                  _isLoadingReviews
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _fetchReviews, // Allow manual refresh
                          child: _reviews.isEmpty
                              ? const Center(child: Text('No reviews yet'))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _reviews.length,
                                  itemBuilder: (context, index) => _buildReviewCard(
                                    name: _reviews[index]['name'] ?? 'Anonymous',
                                    rating: _reviews[index]['rating']?.toInt() ?? 0,
                                    comment: _reviews[index]['comment'] ?? '',
                                    date: _formatDate(_reviews[index]['date']),
                                    isDarkMode: isDarkMode,
                                  ),
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

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white : Colors.black),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String name,
    required int rating,
    required String comment,
    required String date,
    required bool isDarkMode,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: index < rating ? Colors.amber : Colors.grey,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[500] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is String) {
      return date; // If date is already a string, return it as is
    } else if (date is DateTime) {
      return date.toString().substring(0, 10); // Format DateTime to YYYY-MM-DD
    } else if (date != null) {
      try {
        return DateTime.parse(date.toString()).toString().substring(0, 10);
      } catch (e) {
        return 'Unknown Date';
      }
    }
    return 'Unknown Date';
  }
}