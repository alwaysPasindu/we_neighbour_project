import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: Color(0xFF0E69D5),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Add your logo image
                      height: 75,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 0),
                const Text(
                  'Hello, John...!',
                  style: AppTextStyles.greeting,
                ),
              ],
            ),
            const Icon(Icons.notifications, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
