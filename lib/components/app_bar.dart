import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    Key? key,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (onBackPressed != null)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.white),
              onPressed: onBackPressed,
            ),
          const Spacer(),
          Image.asset(
            'assets/we_neighbour_logo.jpeg',
            height: 100, 
            width: 100,  
          ),
        ],
      ),
    );
  }
}