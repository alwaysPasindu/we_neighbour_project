import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.imageUrl,
    this.radius = 50,
  });

  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        image: imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(
              Icons.person,
              size: radius,
              color: Colors.grey[800],
            )
          : null,
    );
  }
}

