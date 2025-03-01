import 'package:flutter/material.dart';
import '../../../models/chat_user.dart';

class OnlineIndicator extends StatelessWidget {
  final UserStatus status;
  final double size;

  const OnlineIndicator({
    Key? key,
    required this.status,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case UserStatus.online:
        color = Colors.green;
        break;
      case UserStatus.away:
        color = Colors.orange;
        break;
      case UserStatus.offline:
        color = Colors.grey;
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 2,
        ),
      ),
    );
  }
}

