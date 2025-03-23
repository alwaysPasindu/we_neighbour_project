import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/constants/text_styles.dart';
import 'package:we_neighbour/main.dart';
import 'package:we_neighbour/models/image_service.dart';
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
import 'package:we_neighbour/models/resource.dart';

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
    _loadUserData().then((_) => _fetchResources());
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
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
      if (!mounted) return; // Check before using context
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
        setState(() {
          resources = data.map((r) => model.Resource.fromJson(r)).toList();
          _isLoading = false;
        });
        logger.d('ResourceSharingPage: Resources fetched successfully - count: ${resources.length}');
      } else {
        throw Exception('Failed to load resources: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return; // Check if still mounted
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching resources: $e')),
      );
      logger.d('ResourceSharingPage: Error fetching resources: $e');
    }
  }

  Future<void> _addResource(String title, String description) async {
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
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Resource request created successfully')),
        );
        logger.d('ResourceSharingPage: Resource created - id: ${newResource.id}');
      } else {
        throw Exception('Failed to create resource: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error creating resource: $e')),
      );
      logger.d('ResourceSharingPage: Error creating resource: $e');
    }
  }

  Future<void> _deleteResource(String id) async {
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
        setState(() {
          resources.removeWhere((resource) => resource!.id == id);
        });
        if (!mounted) return; // Check if still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Resource request deleted successfully')),
        );
        logger.d('ResourceSharingPage: Resource deleted - id: $id');
      } else {
        throw Exception('Failed to delete resource: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return; // Check if still mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error deleting resource: $e')),
      );
      logger.d('ResourceSharingPage: Error deleting resource: $e');
    }
  }

  Future<void> _initiateChat(String resourceUserId, String message) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.currentUserId == null || chatProvider.currentUserId!.isEmpty) {
      if (!mounted) return; // Check before using context
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('👤 User not authenticated. Please log in again.')),
      );
      logger.d('ResourceSharingPage: User not authenticated - currentUserId: ${chatProvider.currentUserId}');
      return;
    }
    try {
      final chatId = await chatProvider.getOrCreateChat(resourceUserId);
      final resourceMessage = "📦 [$resourceUserId] $message";
      await chatProvider.sendResourceMessage(chatId, resourceMessage, resourceUserId);
      logger.d('ResourceSharingPage: Chat initiated - chatId: $chatId, resourceUserId: $resourceUserId');
      if (!mounted) return; // Check if still mounted before navigation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(chatId: chatId, isGroup: false),
        ),
      );
    } catch (e) {
      if (!mounted) return; // Check if still mounted
      logger.d('ResourceSharingPage: Chat initiation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('💬 Error initiating chat: $e')),
      );
    }
  }

  void _showCreateDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    List<XFile> selectedImages = [];
    List<String> imageUrls = [];
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
             
              const SizedBox(width: 8),
              Text(
                'Share a Resource',
                style: AppTextStyles.getGreetingStyle(isDarkMode).copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Resource Name',
                    prefixIcon: const Icon(Icons.category, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.description, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  style: AppTextStyles.getBodyTextStyle(isDarkMode),
                  maxLines: 3,
                ),
                const SizedBox(height: 12), 
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close),
              label: Text('Cancel', style: AppTextStyles.getBodyTextStyle(isDarkMode)),
              style: TextButton.styleFrom(
                foregroundColor: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    descriptionController.text.isEmpty ) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('⚠️ Please fill in all fields')),
                  );
                  return;
                }

                if (selectedImages.isNotEmpty) {
                  for (var image in selectedImages) {
                    final url = await ImageService.uploadImage(image);
                    if (url != null) {
                      imageUrls.add(url);
                    }
                  }
                }

                await _addResource(
                  titleController.text,
                  descriptionController.text
                );
                if (!mounted) return; // Check if still mounted before popping
                Navigator.pop(dialogContext);
              },
              icon: const Icon(Icons.check_circle),
              label: Text('Share', style: AppTextStyles.getButtonTextStyle(isDarkMode)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
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
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber[700]),
            const SizedBox(width: 8),
            Text(
              'Remove Resource',
              style: AppTextStyles.getGreetingStyle(isDarkMode),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove this resource request? This action cannot be undone.',
          style: AppTextStyles.getBodyTextStyle(isDarkMode),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(dialogContext),
            icon: const Icon(Icons.cancel_outlined),
            label: Text('Keep', style: AppTextStyles.getBodyTextStyle(isDarkMode)),
            style: TextButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await _deleteResource(id);
              if (!mounted) return; // Check if still mounted before popping
              Navigator.pop(dialogContext);
            },
            icon: const Icon(Icons.delete_outline),
            label: Text('Remove', style: AppTextStyles.getButtonTextStyle(isDarkMode)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
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
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.inventory_2, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Community Resources',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            tooltip: 'Messages',
            onPressed: () => Navigator.pushNamed(context, '/chat-list'),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Loading resources...',
                    style: AppTextStyles.getBodyTextStyle(isDarkMode),
                  ),
                ],
              ),
            )
          : resources.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: isDarkMode ? Colors.white54 : Colors.black38,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No resources available',
                        style: AppTextStyles.getGreetingStyle(isDarkMode),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to share something!',
                        style: AppTextStyles.getBodyTextStyle(isDarkMode),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showCreateDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Share a Resource'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                )
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
                                await _initiateChat(resource.userId, message);
                              }
                            }
                          : null,
                      onDelete: userId == resource.userId ? () => _showDeleteDialog(resource.id) : null,
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}