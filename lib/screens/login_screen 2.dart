import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';
import '../widgets/social_login_buttons.dart';
import '../utils/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Center(
                child: Text(
                  'WE NEIGHBOUR',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'WELCOME!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CustomTextField(hintText: 'Email'),
            const SizedBox(height: 15),
            const CustomTextField(
              hintText: 'Password',
              isPassword: true,
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('● Remember me'),
                  Text(
                    'Forget password?',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const CustomButton(
              text: 'Login',
              onPressed: null,
            ),
            const SizedBox(height: 10),
            const Text('New user? Register',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontStyle: FontStyle.italic,
                )),
            const SizedBox(height: 20),
            const SocialLoginButtons(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
