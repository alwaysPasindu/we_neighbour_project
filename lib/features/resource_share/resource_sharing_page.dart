import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/models/resource.dart' as model;
import 'package:we_neighbour/widgets/share_dialog.dart';
import '../../constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/widgets/resource_card.dart';
import 'package:we_neighbour/providers/chat_provider.dart';
import 'package:we_neighbour/providers/theme_provider.dart';

class ResourceSharingPage extends StatefulWidget {
  const ResourceSharingPage({super.key});

  @override
  State<ResourceSharingPage> createState() => _ResourceSharingPageState();
}

class _ResourceSharingPageState extends State<ResourceSharingPage> {
  List<model.Resource> resources = [];
  bool _isLoading = true;
  String? userId;
  String? authToken;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _fetchResources();
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      authToken = prefs.getString('token');
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final apartmentName = prefs.getString('userApartment') ?? '';
    if (userId != null && userId!.isNotEmpty && chatProvider.currentUserId != userId) {
      await chatProvider.setUser(userId!, apartmentName);
      print('ChatProvider updated with userId: $userId, apartmentName: $apartmentName');
    }
    print('Loaded user data: userId=$userId, apartmentName=$apartmentName');
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
      final headers = {'x-auth-token': token};
      final response = await http
          .get(Uri.parse('$baseUrl/api/resource/get-request'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            resources = data.map((r) => model.Resource.fromJson(r)).toList();
            _isLoading = false;
          });
          print('Fetched ${resources.length} resources');
        } else {
          throw Exception('Invalid response format: Expected a list');
        }
      } else {
        throw Exception('Failed to load resources: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Fetch resources error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching resources: $e')),
      );
    }
  }

  Future<void> _addResource(String title, String description, String quantity) async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      };
      final body = jsonEncode({
        'resourceName': title,
        'description': description,
        'quantity': quantity,
        'userId': userId,
      });

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/resource/create-request'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final newResource = model.Resource.fromJson(jsonDecode(response.body));
        setState(() {
          resources.insert(0, newResource);
        });
      } else {
        throw Exception('Failed to create resource: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Add resource error: $e');
      throw e; // Re-throw to handle in the dialog
    }
  }

  Future<void> _deleteResource(String id) async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token not found')),
      );
      return;
    }

    try {
      final headers = {'x-auth-token': token};
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/resource/delete-request/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        setState(() {
          resources.removeWhere((resource) => resource.id == id);
        });
      } else {
        throw Exception('Failed to delete resource: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Delete resource error: $e');
      throw e; // Re-throw to handle in the dialog
    }
  }

  void _initiateChat(String resourceUserId, String message, String resourceId) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.currentUserId == null || chatProvider.currentUserId!.isEmpty || FirebaseAuth.instance.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Please log in again.')),
      );
      return;
    }
    print('Initiating chat with user: $resourceUserId, message: $message, resourceId: $resourceId');
    try {
      final chatId = await chatProvider.getOrCreateChat(resourceUserId, resourceId: resourceId);
      print('Chat ID obtained: $chatId');
      await chatProvider.sendMessage(chatId, message);
      print('Message sent successfully');
      Navigator.pushNamed(
        context,
          '/chat-screen',
        arguments: {
          'chatId': chatId,
          'isGroup': false,
          'resourceId': resourceId,
        },
      );
    } catch (e) {
      print('Chat initiation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating chat: $e')),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'New Resource Request',
            style: AppTextStyles.getGreetingStyle(isDarkMode),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Resource Name'),
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                  autocorrect: false, // Disable autocorrect
                  enableSuggestions: false, // Disable predictive text
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                  autocorrect: false, // Disable autocorrect
                  enableSuggestions: false, // Disable predictive text
                ),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                  keyboardType: TextInputType.number,
                  autocorrect: false, // Disable autocorrect
                  enableSuggestions: false, // Disable predictive text
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTextStyles.getBodyTextStyle(isDarkMode)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ||
                    quantityController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }

                try {
                  await _addResource(
                    titleController.text,
                    descriptionController.text,
                    quantityController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resource request created successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error creating resource: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Create', style: AppTextStyles.getButtonTextStyle(isDarkMode)),
            ),
          ],
        ),
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
            onPressed: () async {
              try {
                await _deleteResource(id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Resource request deleted successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting resource: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : resources.isEmpty
              ? const Center(child: Text('No resources available'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: resources.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final resource = resources[index];
                    return ResourceCard(
                      title: resource.title,
                      description: resource.description,
                      userName: resource.userName,
                      apartmentCode: resource.apartmentCode,
                      userId: resource.userId,
                      currentUserId: userId,
                      isDarkMode: isDarkMode,
                      onShare: userId != resource.userId
                          ? () async {
                              final message = await showDialog<String>(
                                context: context,
                                builder: (context) => ShareDialog(resource: resource),
                              );
                              if (message != null && message.isNotEmpty) {
                                _initiateChat(resource.userId, message, resource.id);
                              }
                            }
                          : null,
                      onDelete: userId == resource.userId ? () => _showDeleteDialog(resource.id) : null,
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