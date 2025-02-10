import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
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
                      height: 30,
                    ),
                    const SizedBox(width: 8),
                    const Text('WE NEIGHBOUR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
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
