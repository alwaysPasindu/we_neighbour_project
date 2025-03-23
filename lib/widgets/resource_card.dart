import 'package:flutter/material.dart';
import 'package:we_neighbour/constants/text_styles.dart';

class ResourceCard extends StatelessWidget {
  final String title;
  final String description;
  final String userName;
  final String apartmentCode;
  final String userId; // Creator's user ID
  final String? currentUserId; // Current user's ID to determine button visibility
  final bool isDarkMode;
  final VoidCallback? onShare; // Optional share callback (hidden for creator)
  final VoidCallback? onDelete; // Optional delete callback (shown for creator)

  const ResourceCard({
    super.key,
    required this.title,
    required this.description,
    required this.userName,
    required this.apartmentCode,
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
        // Optional tap behavior (e.g., navigate to details)
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                    onPressed: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Color.fromARGB(255, 117, 117, 117)),
                    const SizedBox(width: 4),
                    Text(
                      'By: $userName',
                      style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Apt: $apartmentCode',
                        style: AppTextStyles.getBodyTextStyle(isDarkMode).copyWith(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                // Show Share button only for non-creators
                if (onShare != null)
                  OutlinedButton(
                    onPressed: onShare,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text(
                      'SHARE',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}