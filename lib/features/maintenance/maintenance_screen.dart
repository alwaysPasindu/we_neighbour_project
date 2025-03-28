import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:we_neighbour/main.dart';
import 'dart:convert';
import 'create_maintenance_request_screen.dart';
import 'package:we_neighbour/utils/auth_utils.dart';
import 'package:logger/logger.dart';

class MaintenanceCard {
  final String id;
  final String title;
  final String description;
  final String status;
  double? averageRating;
  List<Map<String, dynamic>>? ratings;

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
  String? _userId;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchRequests();
  }

  Future<void> _loadUserId() async {
    _userId = await AuthUtils.getUserId();
    logger.d('Loaded User ID: $_userId');
    if (mounted) setState(() {});
  }

  Future<void> _fetchRequests() async {
    try {
      final url = widget.isManager
          ? '$baseUrl/api/maintenance/get-pending-request'
          : '$baseUrl/api/maintenance/get-completed-request';

      logger.d(
          'Fetching requests for ${widget.isManager ? "Manager" : "Resident"} with URL: $url');
      logger.d('Fetching requests with token: ${widget.authToken}');
      logger.d('Authorization header: x-auth-token: ${widget.authToken}');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'x-auth-token': widget.authToken,
        },
      );

      logger.d('Fetch requests status code: ${response.statusCode}');
      logger.d('Fetch requests response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _requests = data.map((r) => MaintenanceCard.fromJson(r)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception(
            'Failed to load requests: Status ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return; // Check if still mounted before using context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Failed to load requests: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      logger.d('Fetch requests error: $e');
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

      logger.d('Mark as done status code: ${response.statusCode}');
      logger.d('Mark as done response body: ${response.body}');

      if (response.statusCode == 200) {
        await _fetchRequests();
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Request marked as completed'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        throw Exception('Failed to mark as done: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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

      logger.d('Rate request status code: ${response.statusCode}');
      logger.d('Rate request response body: ${response.body}');

      if (response.statusCode == 200) {
        await _fetchRequests();
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.thumb_up, color: Colors.white),
                SizedBox(width: 12),
                Text('Rating submitted successfully'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(data['message'] ?? 'Rating failed')),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        throw Exception('Failed to submit rating: ${response.body}');
      }
    } catch (e) {
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Error: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xFF4080FF);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0A1A3B) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDarkMode ? Colors.white : Colors.black87,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isManager ? 'Pending Maintenance' : 'Completed Maintenance',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: _fetchRequests,
          ),
        ],
      ),
      body: _isLoading || _userId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading requests...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isManager
                            ? Icons.build_circle_outlined
                            : Icons.check_circle_outline,
                        size: 64,
                        color: isDarkMode ? Colors.white38 : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.isManager
                            ? 'No pending maintenance requests'
                            : 'No completed maintenance requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white70 : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isManager
                            ? 'All maintenance requests have been completed'
                            : 'Submit a new request using the button below',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white60 : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchRequests,
                  color: primaryColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _requests.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _buildMaintenanceCard(
                            _requests[index], isDarkMode);
                      },
                    ),
                  ),
                ),
      floatingActionButton: widget.isManager
          ? null
          : FloatingActionButton.extended(
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text(
                'New Request',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildMaintenanceCard(MaintenanceCard card, bool isDarkMode) {
    final userRating = card.ratings?.firstWhere(
      (rating) => rating['resident']['_id'] == _userId,
      orElse: () => {'stars': 0},
    )['stars'];

    final totalReviews = card.ratings?.length ?? 0;
    const primaryColor = Color(0xFF4080FF);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1C2F4F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08) ,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.home_repair_service_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    card.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(card.status).withValues(alpha: 0.1) ,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(card.status).withValues(alpha: 0.5) ,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getFormattedStatus(card.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(card.status),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      card.description,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF162844) : Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.white10 : Colors.grey[200]!,
                ),
              ),
            ),
            child: widget.isManager
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _markAsDone(card.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Mark Complete',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (card.averageRating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              card.averageRating!.toStringAsFixed(1),
                              style: TextStyle(
                                color:
                                    isDarkMode ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($totalReviews)',
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (starIndex) {
                          return GestureDetector(
                            onTap: () => _rateRequest(card.id, starIndex + 1),
                            child: Icon(
                              starIndex < (userRating ?? 0)
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: starIndex < (userRating ?? 0)
                                  ? Colors.amber
                                  : isDarkMode
                                      ? Colors.white60
                                      : Colors.grey[400],
                              size: 24,
                            ),
                          );
                        }),
                      ),
                      if (userRating != null && userRating > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Center(
                            child: Text(
                              'Your rating: $userRating/5',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? Colors.white60
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'done':
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getFormattedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'in progress':
        return 'In Progress';
      case 'done':
        return 'Completed';
      default:
        return status
            .split('_')
            .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }
}
