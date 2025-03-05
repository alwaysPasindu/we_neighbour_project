import 'package:flutter/material.dart';
import 'package:we_neighbour/constants/colors.dart';
import 'package:we_neighbour/constants/text_styles.dart';

class ResourceCard extends StatelessWidget {
  final String title;
  final String description;
  final String requestId;
  final String userName;
  final String userId; // Creator's user ID
  final String? currentUserId; // Current user's ID to determine button visibility
  final bool isDarkMode;
  final VoidCallback? onShare; // Optional share callback (hidden for creator)
  final VoidCallback? onDelete; // Optional delete callback (shown for creator)

  const ResourceCard({
    super.key,
    required this.title,
    required this.description,
    required this.requestId,
    required this.userName,
    required this.userId,
    required this.currentUserId,
    required this.isDarkMode,
    this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // You can add tap behavior here if needed (e.g., navigate to details)
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
                const Text(
                  '⚙️', // Gear icon for resources
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.getSubtitleStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, // Slightly larger for emphasis
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description.length > 50
                            ? '${description.substring(0, 50)}...'
                            : description,
                        style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Show Delete button only for the creator
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
                // Show Share button only for non-creators
                if (onShare != null)
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: onShare,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'By: $userName • Request ID: $requestId',
              style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
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