import 'package:flutter/material.dart';
import 'package:we_neighbour/components/app_bar.dart';
import 'package:we_neighbour/main.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class SafetyAlert {
  final String id;
  final String title;
  final String description;
  final String createdByName;
  final DateTime createdAt;

  SafetyAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.createdByName,
    required this.createdAt,
  });

  factory SafetyAlert.fromJson(Map<String, dynamic> json) {
    return SafetyAlert(
      id: json['_id'],
      title: json['title'],
      description: json['description'] ?? json['message'],
      createdByName: json['createdBy']['name'] ?? 'Unknown',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class SafetyAlertsScreen extends StatefulWidget {
  const SafetyAlertsScreen({super.key});

  @override
  State<SafetyAlertsScreen> createState() => _SafetyAlertsScreenState();
}

class _SafetyAlertsScreenState extends State<SafetyAlertsScreen> {
  List<SafetyAlert> alerts = [];
  bool _isLoading = true;
  String? userRole;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchAlerts();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole')?.toLowerCase();
      logger.d('Loaded User Role: $userRole');
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    logger.d('Retrieved token: $token');
    return token;
  }

  Future<void> _fetchAlerts() async {
    final token = await _getToken();
    if (token == null) {
      setState(() => _isLoading = false);
      logger.d('No token available');
      return;
    }

    setState(() => _isLoading = true);
    try {
      logger.d('Fetching alerts from: $baseUrl/api/safety-alerts/get-alerts');
      final response = await http.get(
        Uri.parse('$baseUrl/api/safety-alerts/get-alerts'),
        headers: {'x-auth-token': token},
      ).timeout(const Duration(seconds: 30));

      logger.d('Fetch response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          alerts = data.map((json) => SafetyAlert.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch alerts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      logger.d('Fetch error: $e');
      setState(() => _isLoading = false);
      if (!mounted) return; // Check if still mounted
      String errorMessage = 'Failed to load alerts: $e';
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot reach server. Check your network or server status.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _createAlert(String title, String description) async {
    final token = await _getToken();
    if (token == null) {
      logger.d('No token available for create');
      return;
    }

    try {
      final requestBody = jsonEncode({'title': title, 'description': description});
      logger.d('Create request: $baseUrl/api/safety-alerts/create-alerts');
      logger.d('Create request body: $requestBody');
      final response = await http.post(
        Uri.parse('$baseUrl/api/safety-alerts/create-alerts'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      logger.d('Create response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        await _fetchAlerts();
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert created successfully')),
        );
      } else if (response.statusCode == 403) {
        throw Exception('Unauthorized: You may not have permission to create alerts');
      } else if (response.statusCode == 500) {
        throw Exception('Server error: Failed to create alert');
      } else {
        throw Exception('Failed to create: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      logger.d('Create error: $e');
      if (!mounted) return; // Check if still mounted
      String errorMessage = 'Error creating alert: $e';
      if (e.toString().contains('Connection refused')) {
        errorMessage = 'Cannot reach server. Check your network or server status.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  Future<void> _deleteAlert(String id) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      logger.d('Delete request: $baseUrl/api/safety-alerts/delete-alerts/$id');
      final response = await http.delete(
        Uri.parse('$baseUrl/api/safety-alerts/delete-alerts/$id'),
        headers: {'x-auth-token': token},
      ).timeout(const Duration(seconds: 15));

      logger.d('Delete response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        await _fetchAlerts();
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert deleted')),
        );
      } else {
        throw Exception('Failed to delete: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      logger.d('Delete error: $e');
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting alert: $e')),
      );
    }
  }

  void _showCreateDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('New Safety Alert', style: AppTextStyles.getGreetingStyle(isDarkMode)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
              autocorrect: false,
              enableSuggestions: false,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
              autocorrect: false,
              enableSuggestions: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: AppTextStyles.getBodyTextStyle(isDarkMode)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please fill in both fields')),
                );
                return;
              }
              _createAlert(titleController.text, descriptionController.text);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? AppColors.primary : const Color.fromARGB(255, 0, 18, 255),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Create', style: AppTextStyles.getButtonTextStyle(isDarkMode)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onBackPressed: () => Navigator.pop(context),
              isDarkMode: isDarkMode,
            ),
            Text(
              'Safety\nAlerts',
              textAlign: TextAlign.center,
              style: AppTextStyles.getGreetingStyle(isDarkMode),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : alerts.isEmpty
                      ? const Center(child: Text('No alerts available'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return SafetyAlertCard(
                              icon: "⚠️",
                              title: alert.title,
                              preview: alert.description.length > 50
                                  ? '${alert.description.substring(0, 50)}...'
                                  : alert.description,
                              fullDescription: alert.description,
                              createdByName: alert.createdByName,
                              createdAt: alert.createdAt,
                              isDarkMode: isDarkMode,
                              onDelete: userRole == 'manager' ? () => _deleteAlert(alert.id) : null,
                            );
                          },
                        ),
            ),
            if (userRole == 'manager')
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: _showCreateDialog,
                    backgroundColor: isDarkMode ? AppColors.primary : const Color.fromARGB(255, 0, 18, 255),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SafetyAlertCard extends StatefulWidget {
  final String icon;
  final String title;
  final String preview;
  final String fullDescription;
  final String createdByName;
  final DateTime createdAt;
  final bool isDarkMode;
  final VoidCallback? onDelete;

  const SafetyAlertCard({
    super.key,
    required this.icon,
    required this.title,
    required this.preview,
    required this.fullDescription,
    required this.createdByName,
    required this.createdAt,
    required this.isDarkMode,
    this.onDelete,
  });

  @override
  State<SafetyAlertCard> createState() => _SafetyAlertCardState();
}

class _SafetyAlertCardState extends State<SafetyAlertCard> {
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showFullDescription = !_showFullDescription),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.isDarkMode ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.getSubtitleStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _showFullDescription ? widget.fullDescription : widget.preview,
                        style: AppTextStyles.getBodyTextStyle(widget.isDarkMode),
                        maxLines: _showFullDescription ? null : 2,
                        overflow: _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: widget.isDarkMode ? Colors.redAccent : Colors.red,
                      size: 20,
                    ),
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'By: ${widget.createdByName} • ${widget.createdAt.toLocal().toString().split('.')[0]}',
              style: AppTextStyles.getBodyTextStyle(widget.isDarkMode).copyWith(
                fontSize: 12,
                color: widget.isDarkMode ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}