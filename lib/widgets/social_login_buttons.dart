import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text('OR',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.facebook, size: 40, color: Colors.black),
            SizedBox(width: 20),
            Icon(Icons.g_translate, size: 40, color: Colors.black),
            SizedBox(width: 20),
            Icon(Icons.close, size: 40, color: Colors.black),
          ],
        ),
        SizedBox(height: 10),
        Text('Sign in with another account'),
      ],
    );
  }
}
