import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/models/resource.dart';
import 'package:we_neighbour/widgets/resource_form_dialog.dart';
import 'package:we_neighbour/widgets/resource_card.dart';
import 'package:we_neighbour/widgets/share_dialog.dart';
import '../../providers/theme_provider.dart';
import '../../constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ResourceSharingPage extends StatefulWidget {
  const ResourceSharingPage({super.key});

  @override
  State<ResourceSharingPage> createState() => _ResourceSharingPageState();
}

class _ResourceSharingPageState extends State<ResourceSharingPage> {
  List<Resource> resources = [];
  bool _isLoading = true;
  String? userId; // To store the current user's ID for authorization
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchResources();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId'); // Get user ID from SharedPreferences
      authToken = prefs.getString('token');
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchResources() async {
    final token = await _getToken();
    if (token == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token available')),
      );
      return;
    }

    try {
      final headers = {'Authorization': 'Bearer $token'};
      print('Fetching resources with headers: $headers');
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/resources/get-request'), // Ensure path matches backend
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('Fetch resources response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          resources = data.map((r) => Resource.fromJson(r)).toList();
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource endpoint not found')),
        );
      } else {
        throw Exception('Failed to load resources: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching resources: $e')),
      );
    }
  }

  Future<void> _addResource(String title, String description, String quantity) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({
        'resourceName': title,
        'description': description,
        'quantity': quantity,
      });
      print('Creating resource with headers: $headers');
      print('Request body: $body');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/resources/create-request'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      print('Create resource response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        final newResource = Resource.fromJson(jsonDecode(response.body)); // Parse the full resource from the 201 response
        setState(() {
          resources.insert(0, newResource); // Add the new resource at the top of the list for instant visibility
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource request created successfully')),
        );
      } else {
        throw Exception('Failed to create resource: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating resource: $e')),
      );
    }
  }

  Future<void> _deleteResource(String id) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final headers = {'Authorization': 'Bearer $token'};
      print('Deleting resource with ID: $id, headers: $headers');
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/resources/delete-request/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('Delete resource response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        setState(() {
          resources.removeWhere((resource) => resource.id == id); // Remove the resource from the list instantly
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource request deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete resource: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting resource: $e')),
      );
    }
  }

  void _showCreateDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'New Resource Request',
          style: AppTextStyles.getGreetingStyle(isDarkMode),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Resource Name'),
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
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              style: AppTextStyles.getBodyTextStyle(isDarkMode),
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              keyboardType: TextInputType.number,
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
              if (titleController.text.isEmpty || descriptionController.text.isEmpty || quantityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }
              _addResource(titleController.text, descriptionController.text, quantityController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? AppColors.primary : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Create', style: AppTextStyles.getButtonTextStyle(isDarkMode)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String id) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Resource Request',
          style: AppTextStyles.getGreetingStyle(isDarkMode),
        ),
        content: Text(
          'Are you sure you want to delete this resource request?',
          style: AppTextStyles.getBodyTextStyle(isDarkMode),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.getBodyTextStyle(isDarkMode)),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteResource(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? AppColors.primary : AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Delete', style: AppTextStyles.getButtonTextStyle(isDarkMode)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Resources',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: resources.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final resource = resources[index];
                return ResourceCard(
                  title: resource.title,
                  description: resource.description,
                  requestId: resource.requestId,
                  userName: resource.userName,
                  userId: resource.userId, // Pass the creator's user ID to ResourceCard
                  currentUserId: userId, // Pass the current user's ID to determine visibility
                  isDarkMode: isDarkMode,
                  onShare: userId != resource.userId // Only show share for non-creators
                      ? () async {
                          final message = await showDialog(
                            context: context,
                            builder: (context) => ShareDialog(resource: resource),
                          );
                          if (message != null) {
                            // Here you would implement the actual message sending logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Message sent to ${resource.userName}'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        }
                      : null, // Hide share for creator
                  onDelete: userId == resource.userId // Only show delete for creator
                      ? () => _showDeleteDialog(resource.id)
                      : null,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}