import 'package:flutter/material.dart';
import 'package:we_neighbour/components/app_bar.dart';
import 'package:we_neighbour/main.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityNotification {
  final String id;
  final String title;
  final String message;
  final String createdByName;
  final DateTime createdAt;

  CommunityNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdByName,
    required this.createdAt,
  });

  factory CommunityNotification.fromJson(Map<String, dynamic> json) {
    return CommunityNotification(
      id: json['_id'],
      title: json['title'],
      message: json['message'],
      createdByName: json['createdBy']['name'] ?? 'Unknown',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class CommunityNotificationsScreen extends StatefulWidget {
  const CommunityNotificationsScreen({super.key});

  @override
  _CommunityNotificationsScreenState createState() => _CommunityNotificationsScreenState();
}

class _CommunityNotificationsScreenState extends State<CommunityNotificationsScreen> {
  List<CommunityNotification> notifications = [];
  String? userRole;
  String? currentUserId; // To check if the user is the creator

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _fetchNotifications();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole')?.toLowerCase();
      currentUserId = prefs.getString('userId'); // Load current user's ID
      print('Loaded User Role: $userRole');
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Retrieved Token: $token');
    return token;
  }

  Future<void> _fetchNotifications() async {
    final token = await _getToken();
    if (token == null) {
      print('No token available for fetching community notifications');
      return;
    }

    try {
      final headers = {'Authorization': 'Bearer $token'};
      print('Fetching with headers: $headers');
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/notifications/community'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('Fetch response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          notifications = data.map((notification) => CommunityNotification.fromJson(notification)).toList();
        });
      } else {
        print('Failed to fetch community notifications: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching community notifications: $e');
    }
  }

  Future<void> _createNotification(String title, String message) async {
    final token = await _getToken();
    if (token == null) {
      print('No token available for creating community notification');
      return;
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({'title': title, 'message': message});
      print('Creating with headers: $headers');
      print('Request body: $body');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/notifications/community'),
            headers: headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      print('Create response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification created successfully')),
        );
        _fetchNotifications();
      } else {
        print('Failed to create community notification: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create notification: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error creating community notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteNotification(String id) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final headers = {'Authorization': 'Bearer $token'};
      print('Deleting community notification with ID: $id, headers: $headers');
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/notifications/community/$id'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('Delete notification response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        _fetchNotifications(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete notification: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  Future<void> _removeNotificationForUser(String id) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final headers = {'Authorization': 'Bearer $token'};
      print('Removing community notification for user with ID: $id, headers: $headers');
      final response = await http
          .delete(
            Uri.parse('$baseUrl/api/notifications/community/$id/remove-for-user'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      print('Remove for user response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        _fetchNotifications(); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification removed for you')),
        );
      } else {
        throw Exception('Failed to remove notification for user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing notification: $e')),
      );
    }
  }

  void _showCreateDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'New Community Notification',
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
              controller: messageController,
              decoration: const InputDecoration(labelText: 'Message'),
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
              if (titleController.text.isEmpty || messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in both title and message')),
                );
                return;
              }
              _createNotification(titleController.text, messageController.text);
              Navigator.pop(context);
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
              'Community\nNotifications',
              textAlign: TextAlign.center,
              style: AppTextStyles.getGreetingStyle(isDarkMode),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text('No notifications available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return CommunityNotificationCard(
                          icon: "📢",
                          title: notification.title,
                          preview: notification.message.length > 50
                              ? '${notification.message.substring(0, 50)}...'
                              : notification.message,
                          fullMessage: notification.message,
                          createdByName: notification.createdByName,
                          createdAt: notification.createdAt,
                          isDarkMode: isDarkMode,
                          onDelete: userRole == 'manager' || currentUserId == notification.id.split('_')[0]
                              ? () => _deleteNotification(notification.id)
                              : null, // Managers and creators can delete for all
                          onRemoveForUser: userRole == 'resident' || userRole == 'manager'
                              ? () => _removeNotificationForUser(notification.id)
                              : null, // Residents and managers can remove for themselves
                        );
                      },
                    ),
            ),
            if (userRole == 'resident' || userRole == 'manager') // Residents and managers can create
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: _showCreateDialog,
                    backgroundColor: isDarkMode ? AppColors.primary : const Color.fromARGB(255, 0, 18, 255),
                    elevation: isDarkMode ? 2 : 0,
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

class CommunityNotificationCard extends StatefulWidget {
  final String icon;
  final String title;
  final String preview;
  final String fullMessage;
  final String createdByName;
  final DateTime createdAt;
  final bool isDarkMode;
  final VoidCallback? onDelete; // Optional delete callback for managers or creators
  final VoidCallback? onRemoveForUser; // Optional remove for user callback for residents/managers

  const CommunityNotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.preview,
    required this.fullMessage,
    required this.createdByName,
    required this.createdAt,
    required this.isDarkMode,
    this.onDelete,
    this.onRemoveForUser,
  });

  @override
  State<CommunityNotificationCard> createState() => _CommunityNotificationCardState();
}

class _CommunityNotificationCardState extends State<CommunityNotificationCard> {
  bool _showFullMessage = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showFullMessage = !_showFullMessage;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? AppColors.darkCardBackground : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.isDarkMode ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _showFullMessage ? widget.fullMessage : widget.preview,
                        style: AppTextStyles.getBodyTextStyle(widget.isDarkMode),
                        maxLines: _showFullMessage ? null : 2,
                        overflow: _showFullMessage ? TextOverflow.visible : TextOverflow.ellipsis,
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
            if (widget.onRemoveForUser != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: widget.onRemoveForUser,
                  child: Text(
                    'Remove for Me',
                    style: AppTextStyles.getBodyTextStyle(widget.isDarkMode).copyWith(
                      color: widget.isDarkMode
                          ? AppColors.primary
                          : const Color.fromARGB(255, 0, 18, 255),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}