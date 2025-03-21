import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:we_neighbour/main.dart';
import 'dart:convert';
import 'create_maintenance_request_screen.dart';
import 'package:we_neighbour/utils/auth_utils.dart'; // Import AuthUtils

class MaintenanceCard {
  final String id;
  final String title;
  final String description;
  final String status;
  double? averageRating;
  List<Map<String, dynamic>>? ratings; // Add ratings list to track individual ratings

  MaintenanceCard({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.averageRating,
    this.ratings,
  });

  factory MaintenanceCard.fromJson(Map<String, dynamic> json) {
    return MaintenanceCard(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      averageRating: json['averageRating']?.toDouble(),
      ratings: json['ratings'] != null
          ? List<Map<String, dynamic>>.from(json['ratings'].map((r) => {
                'resident': r['resident'],
                'stars': r['stars'],
              }))
          : null,
    );
  }
}

class MaintenanceScreen extends StatefulWidget {
  final String authToken;
  final bool isManager;

  const MaintenanceScreen({
    super.key,
    required this.authToken,
    required this.isManager,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  List<MaintenanceCard> _requests = [];
  bool _isLoading = true;
  String? _userId; // Store user ID

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load user ID first
    _fetchRequests();
  }

  Future<void> _loadUserId() async {
    _userId = await AuthUtils.getUserId(); // Use AuthUtils to get user ID
    print('Loaded User ID: $_userId');
    if (mounted) setState(() {}); // Force rebuild after loading user ID
  }

  Future<void> _fetchRequests() async {
    try {
      final url = widget.isManager
          ? '$baseUrl/api/maintenance/get-pending-request'
          : '$baseUrl/api/maintenance/get-completed-request';
      
      print('Fetching requests for ${widget.isManager ? "Manager" : "Resident"} with URL: $url');
      print('Fetching requests with token: ${widget.authToken}');
      print('Authorization header: x-auth-token: ${widget.authToken}');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-auth-token': widget.authToken,
        },
      );

      print('Fetch requests status code: ${response.statusCode}');
      print('Fetch requests response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _requests = data.map((r) => MaintenanceCard.fromJson(r)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load requests: Status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load requests: ${e.toString()}')),
        );
        print('Fetch requests error: $e');
      }
    }
  }

  Future<void> _markAsDone(String id) async {
    if (!widget.isManager) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/maintenance/mark-request/$id/done'),
        headers: {
          'x-auth-token': widget.authToken,
        },
      );

      print('Mark as done status code: ${response.statusCode}');
      print('Mark as done response body: ${response.body}');

      if (response.statusCode == 200) {
        _fetchRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request marked as done')),
        );
      } else {
        throw Exception('Failed to mark as done: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _rateRequest(String id, int rating) async {
    if (widget.isManager) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/maintenance/rate/$id'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': widget.authToken,
        },
        body: jsonEncode({'stars': rating}),
      );

      print('Rate request status code: ${response.statusCode}');
      print('Rate request response body: ${response.body}');

      if (response.statusCode == 200) {
        _fetchRequests(); // Refresh requests to update ratings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted')),
        );
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Rating failed')),
        );
      } else {
        throw Exception('Failed to submit rating: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isManager ? 'Pending Maintenance' : 'Completed Maintenance',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading || _userId == null
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _requests.length,
              itemBuilder: (context, index) {
                return _buildMaintenanceCard(_requests[index], isDarkMode);
              },
            ),
      floatingActionButton: widget.isManager
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF4080FF),
              child: const Icon(Icons.add, size: 32),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateMaintenanceRequestScreen(
                      authToken: widget.authToken,
                    ),
                  ),
                );
                if (result == true) {
                  _fetchRequests();
                }
              },
            ),
    );
  }

  Widget _buildMaintenanceCard(MaintenanceCard card, bool isDarkMode) {
    // Get user's rating (if any) based on their ID
    final userRating = card.ratings?.firstWhere(
      (rating) => rating['resident']['_id'] == _userId, // Use actual user ID
      orElse: () => {'stars': 0},
    )['stars'];

    // Count total reviews
    final totalReviews = card.ratings?.length ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4080FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              card.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.isManager)
            ElevatedButton(
              onPressed: () => _markAsDone(card.id),
              child: const Text('Mark Done'),
            )
          else ...[
            if (card.averageRating != null)
              Text(
                'Avg: ${card.averageRating} ($totalReviews reviews)', // Show total reviews
                style: const TextStyle(color: Colors.white),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (starIndex) {
                return GestureDetector(
                  onTap: () => _rateRequest(card.id, starIndex + 1),
                  child: Icon(
                    Icons.star,
                    color: starIndex < (userRating ?? 0)
                        ? Colors.amber // Filled star if rated
                        : Colors.white, // Empty star if not rated
                    size: 20,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}