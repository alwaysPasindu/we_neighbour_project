import 'package:flutter/material.dart';
import 'package:we_neighbour/components/app_bar.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
      description: json['description'],
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
  String? authToken;
  String? currentUserId; // To check if the user is the creator

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchAlerts();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole')?.toLowerCase();
      authToken = prefs.getString('token');
      currentUserId = prefs.getString('userId'); // Load current user's ID
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchAlerts() async {
    final token = await _getToken();
    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final headers = {'Authorization': 'Bearer $token'};
      print('Fetching safety alerts with headers: $headers');
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/safety-alerts/get-alerts'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('Fetch safety alerts response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          alerts = data.map((alert) => SafetyAlert.fromJson(alert)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load safety alerts: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching safety alerts: $e')),
      );
    }
  }

  Future<void> _createAlert(String title, String description) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({'title': title, 'description': description});
      print('Creating safety alert with headers: $headers');
      print('Request body: $body');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/safety-alerts/create-alerts'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      print('Create safety alert response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        _fetchAlerts(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safety alert created successfully')),
        );
      } else {
        throw Exception('Failed to create safety alert: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating safety alert: $e')),
      );
    }
  }

  Future<void> _deleteAlert(String id) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final headers = {'Authorization': 'Bearer $token'};
      print('Deleting safety alert with ID: $id, headers: $headers');
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/safety-alerts/delete-alerts/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('Delete safety alert response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        _fetchAlerts(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Safety alert deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete safety alert: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting safety alert: $e')),
      );
    }
  }

  void _showCreateDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color.fromARGB(255, 146, 4, 4) : const Color.fromARGB(255, 146, 4, 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'New Safety Alert',
          style: AppTextStyles.getGreetingStyle(isDarkMode),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.getBodyTextStyle(isDarkMode)),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in both title and description')),
                );
                return;
              }
              _createAlert(titleController.text, descriptionController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.white : Colors.black,
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
      backgroundColor: isDarkMode ? const Color.fromARGB(255, 146, 4, 4) : const Color.fromARGB(255, 146, 4, 4),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              onBackPressed: () => Navigator.pop(context),
              isDarkMode: isDarkMode,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'SAFETY ALERTS',
                style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(
                  color: Colors.white, // White text for red background contrast
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : alerts.isEmpty
                      ? const Center(child: Text('No safety alerts available', style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return SafetyAlertCard(
                              icon: "⚠️", // Warning icon for safety alerts
                              title: alert.title,
                              preview: alert.description.length > 50
                                  ? '${alert.description.substring(0, 50)}...'
                                  : alert.description,
                              fullDescription: alert.description,
                              createdByName: alert.createdByName,
                              createdAt: alert.createdAt,
                              isDarkMode: isDarkMode,
                              onDelete: (userRole == 'manager' || currentUserId == alert.id.split('_')[0])
                                  ? () => _deleteAlert(alert.id)
                                  : null, // Managers can delete any, residents can delete their own
                            );
                          },
                        ),
            ),
            if (userRole == 'manager') // Only managers can create
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: _showCreateDialog,
                    backgroundColor: Colors.white,
                    elevation: isDarkMode ? 2 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add, color: Colors.red),
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
  final VoidCallback? onDelete; // Optional delete callback for managers or creators

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
      onTap: () {
        setState(() {
          _showFullDescription = !_showFullDescription;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                Text(
                  widget.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.getSubtitleStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Slightly larger for emphasis
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _showFullDescription ? widget.fullDescription : widget.preview,
                        style: AppTextStyles.getBodyTextStyle(widget.isDarkMode).copyWith(
                          color: Colors.black54,
                        ),
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
                      color: Colors.red,
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
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}