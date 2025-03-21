import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onBackPressed;
  
  final bool isDarkMode;

  const CustomAppBar({
    Key? key,
    this.onBackPressed, 
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(11.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center logo
          Center(
            child: Image.asset(
              isDarkMode 
                ? 'assets/images/logo.png'  // Dark mode logo
                : 'assets/images/logo_dark.png',      // Light mode logo
              height: 120,
              width: 100,
            ),
          ),
          // Back button positioned on the left
          if (onBackPressed != null)
            Positioned(
              left: 0,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDarkMode ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: onBackPressed,
              ),
            ),
        ],
      ),
    );
  }
}