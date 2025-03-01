import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_neighbour/models/resource.dart';
import 'package:we_neighbour/widgets/resource_form_dialog.dart';
import 'package:we_neighbour/widgets/resource_card.dart';
import 'package:we_neighbour/widgets/share_dialog.dart';
import '../../providers/theme_provider.dart';
import '../../constants/colors.dart';

class ResourceSharingPage extends StatefulWidget {
  const ResourceSharingPage({super.key});

  @override
  State<ResourceSharingPage> createState() => _ResourceSharingPageState();
}

class _ResourceSharingPageState extends State<ResourceSharingPage> {
  List<Resource> resources = [
    Resource(
      id: '1',
      title: 'Chair',
      description: 'I need a chair for night party',
      requestId: '92287157',
      userId: 'user1',
      userName: 'John Doe',
    ),
    Resource(
      id: '2',
      title: 'Table',
      description: 'I need a table ',
      requestId: '92287158',
      userId: 'user2',
      userName: 'Jane Smith',
    ),
  ];

  Future<void> _addResource() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const ResourceFormDialog(),
    );

    if (result != null) {
      setState(() {
        resources.add(
          Resource(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: result['title'],
            description: result['description'],
            requestId: 'REQ${DateTime.now().millisecondsSinceEpoch}',
            userId: 'currentUserId', // Replace with actual user ID
            userName: 'Current User', // Replace with actual user name
          ),
        );
      });
    }
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
      body: ListView.separated(
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
            isDarkMode: isDarkMode,
            onShare: () async {
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
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addResource,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}