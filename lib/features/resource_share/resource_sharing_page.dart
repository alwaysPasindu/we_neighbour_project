// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/models/resource.dart' as model;
import 'package:we_neighbour/widgets/share_dialog.dart';
import '../../constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_neighbour/widgets/resource_card.dart';
import 'package:we_neighbour/features/chat/chat_screen.dart';
import 'package:we_neighbour/providers/chat_provider.dart';
import 'package:we_neighbour/providers/theme_provider.dart';
import 'package:logger/logger.dart';

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
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUserData();
    await _fetchResources();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userId = prefs.getString('userId');
      authToken = prefs.getString('token');
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final apartmentName = prefs.getString('userApartment') ?? 'UnknownApartment';
    if (userId != null && userId!.isNotEmpty && chatProvider.currentUserId != userId) {
      chatProvider.setUser(userId!, apartmentName);
      logger.d('ResourceSharingPage: User data loaded - userId: $userId, apartmentName: $apartmentName');
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchResources() async {
    final token = await _getToken();
    if (token == null) {
      if (!mounted) return;
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
        final List<dynamic> data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          resources = data.map((r) => model.Resource.fromJson(r)).toList();
          _isLoading = false;
        });
        logger.d('ResourceSharingPage: Resources fetched successfully - count: ${resources.length}');
      } else {
        throw Exception('Failed to load resources: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching resources: $e')),
      );
      logger.d('ResourceSharingPage: Error fetching resources: $e');
    }
  }

  Future<void> _addResource(
    String title,
    String description,
    String quantity,
    List<String> imageUrls,
    BuildContext dialogContext,
  ) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final headers = {
        'Content-Type': 'application/json',
        'x-auth-token': token,
      };
      final body = jsonEncode({
        'resourceName': title,
        'description': description,
        'quantity': quantity,
        'images': imageUrls,
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
        if (!mounted) return;
        setState(() {
          resources.insert(0, newResource);
        });
        if (!dialogContext.mounted) return;
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          const SnackBar(content: Text('Resource request created successfully')),
        );
        logger.d('ResourceSharingPage: Resource created - id: ${newResource.id}');
      } else {
        throw Exception('Failed to create resource: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (!dialogContext.mounted) return;
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text('Error creating resource: $e')),
      );
      logger.d('ResourceSharingPage: Error creating resource: $e');
    }
  }

  Future<void> _deleteResource(String id, BuildContext dialogContext) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final headers = {'x-auth-token': token};
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/resource/delete-request/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          resources.removeWhere((resource) => resource.id == id);
        });
        if (!dialogContext.mounted) return;
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          const SnackBar(content: Text('Resource request deleted successfully')),
        );
        logger.d('ResourceSharingPage: Resource deleted - id: $id');
      } else {
        throw Exception('Failed to delete resource: ${response.statusCode}');
      }
    } catch (e) {
      if (!dialogContext.mounted) return;
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text('Error deleting resource: $e')),
      );
      logger.d('ResourceSharingPage: Error deleting resource: $e');
    }
  }

  Future<void> _showDeleteDialog(String resourceId) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Resource'),
        content: const Text('Are you sure you want to delete this resource?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteResource(resourceId, context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _initiateChat(String resourceUserId, String message) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.currentUserId == null || chatProvider.currentUserId!.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Please log in again.')),
      );
      logger.d('ResourceSharingPage: User not authenticated - currentUserId: ${chatProvider.currentUserId}');
      return;
    }
    try {
      final chatId = await chatProvider.getOrCreateChat(resourceUserId);
      final resourceMessage = "[Resource Share] $message";
      await chatProvider.sendResourceMessage(chatId, resourceMessage, resourceUserId);
      logger.d('ResourceSharingPage: Chat initiated - chatId: $chatId, resourceUserId: $resourceUserId');
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: chatId, isGroup: false),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      logger.d('ResourceSharingPage: Chat initiation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating chat: $e')),
      );
    }
  }

  Future<void> _showCreateDialog() async {
    if (!mounted) return;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    List<String> imageUrls = [];

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Create Resource'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && descriptionController.text.isNotEmpty) {
                _addResource(
                  titleController.text,
                  descriptionController.text,
                  quantityController.text,
                  imageUrls,
                  dialogContext,
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Create'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () => Navigator.pushNamed(context, '/chat-list'),
          ),
        ],
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
                          if (message != null && message.isNotEmpty && mounted) {
                            await _initiateChat(resource.userId, message);
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