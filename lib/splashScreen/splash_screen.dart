import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _slideAnimation;

  // For animated particles
  final List<Map<String, dynamic>> _particles = [];
  // final int _particleCount = 20;

  @override
  void initState() {
    super.initState();

    // Generate random particles
    // _generateParticles();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Create animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate to login page after delay
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  // void _generateParticles() {
  //   final random = math.Random();
  //   for (int i = 0; i < _particleCount; i++) {
  //     _particles.add({
  //       'x': random.nextDouble(),
  //       'y': random.nextDouble(),
  //       'size': random.nextDouble() * 10 + 2,
  //       'speed': random.nextDouble() * 0.8 + 0.2,
  //       'opacity': random.nextDouble() * 0.6 + 0.2,
  //     });
  //   }
  // }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color.fromARGB(255, 0, 18, 152);
    const secondaryColor = Color.fromARGB(255, 18, 115, 234);

    return Scaffold(
      body: Stack(
        children: [
          // Animated background with gradient
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDarkMode
                    ? [
                        primaryColor,
                        secondaryColor.withValues(alpha: 0.8),
                      ]
                    : [
                        const Color.fromARGB(255, 73, 151, 247),
                        const Color.fromARGB(255, 37, 121, 255),
                      ],
              ),
            ),
          ),

          // Animated particles
          ...List.generate(_particles.length, (index) {
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                final particle = _particles[index];
                final posX = particle['x'] * size.width;
                final posY = particle['y'] * size.height;
                final particleSize = particle['size'];
                final speed = particle['speed'];
                final opacity = particle['opacity'] * _fadeAnimation.value;

                return Positioned(
                  left: posX,
                  top: posY +
                      (30 *
                          math.sin(_animationController.value *
                              math.pi *
                              2 *
                              speed)),
                  child: Container(
                    width: particleSize,
                    height: particleSize,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: opacity),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: opacity * 0.5),
                          blurRadius: particleSize * 2,
                          spreadRadius: particleSize * 0.2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),

          // Decorative circles
          Positioned(
            top: -size.width * 0.4,
            right: -size.width * 0.3,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _animationController.value * 0.2,
                  child: Container(
                    width: size.width * 0.8,
                    height: size.width * 0.8,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: -size.width * 0.6,
            left: -size.width * 0.3,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -_animationController.value * 0.2,
                  child: Container(
                    width: size.width * 0.9,
                    height: size.width * 0.9,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 1.0],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content with animations
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo with reflection
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Logo - Shadow removed
                      Container(
                        width: 180,
                        height: 180,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 180,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Modern loading indicator
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, _) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: -5,
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.9),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // App name with animated slide
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      const SizedBox(height: 15),

                      // Tagline with animated typing effect
                      SizedBox(
                        height: 20,
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, _) {
                            const String fullText =
                                "Connecting Communities · Simplifying Life";
                            final int textLength =
                                (fullText.length * _animationController.value)
                                    .round();
                            final String visibleText = fullText.substring(
                                0, textLength.clamp(0, fullText.length));

                            return Text(
                              visibleText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Version number at bottom
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: const Text(
                    "Version 1.0.0",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:math' as math;
// import 'dart:ui';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _rotationAnimation;
//   late Animation<double> _slideAnimation;

//   // For animated particles
//   final List<Map<String, dynamic>> _particles = [];
//   // final int _particleCount = 20;

//   @override
//   void initState() {
//     super.initState();

//     // Generate random particles
//     // _generateParticles();

//     // Initialize animation controller
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 2500),
//     );

//     // Create animations
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
//       ),
//     );

//     _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
//       ),
//     );

//     _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
//       ),
//     );

//     // Start animation
//     _animationController.forward();

//     // Navigate to login page after delay
//     Timer(const Duration(seconds: 3), () {
//       Navigator.pushReplacementNamed(context, '/login');
//     });
//   }

//   // void _generateParticles() {
//   //   final random = math.Random();
//   //   for (int i = 0; i < _particleCount; i++) {
//   //     _particles.add({
//   //       'x': random.nextDouble(),
//   //       'y': random.nextDouble(),
//   //       'size': random.nextDouble() * 10 + 2,
//   //       'speed': random.nextDouble() * 0.8 + 0.2,
//   //       'opacity': random.nextDouble() * 0.6 + 0.2,
//   //     });
//   //   }
//   // }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     const primaryColor = Color.fromARGB(255, 0, 18, 152);
//     const secondaryColor = Color.fromARGB(255, 18, 115, 234);

//     return Scaffold(
//       body: Stack(
//         children: [
//           // Animated background with gradient
//           Container(
//             width: size.width,
//             height: size.height,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: isDarkMode
//                     ? [
//                         primaryColor,
//                         secondaryColor.withValues(alpha: 0.8),
//                       ]
//                     : [
//                         const Color.fromARGB(255, 73, 151, 247),
//                         const Color.fromARGB(255, 37, 121, 255),
//                       ],
//               ),
//             ),
//           ),

//           // Animated particles
//           ...List.generate(_particles.length, (index) {
//             return AnimatedBuilder(
//               animation: _animationController,
//               builder: (context, _) {
//                 final particle = _particles[index];
//                 final posX = particle['x'] * size.width;
//                 final posY = particle['y'] * size.height;
//                 final particleSize = particle['size'];
//                 final speed = particle['speed'];
//                 final opacity = particle['opacity'] * _fadeAnimation.value;

//                 return Positioned(
//                   left: posX,
//                   top: posY +
//                       (30 *
//                           math.sin(_animationController.value *
//                               math.pi *
//                               2 *
//                               speed)),
//                   child: Container(
//                     width: particleSize,
//                     height: particleSize,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(opacity),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.white.withOpacity(opacity * 0.5),
//                           // color: Colors.white.withOpacity(opacity * 0.5),
//                           blurRadius: particleSize * 2,
//                           spreadRadius: particleSize * 0.2,
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }),

//           // Decorative circles
//           Positioned(
//             top: -size.width * 0.4,
//             right: -size.width * 0.3,
//             child: AnimatedBuilder(
//               animation: _animationController,
//               builder: (context, child) {
//                 return Transform.rotate(
//                   angle: _animationController.value * 0.2,
//                   child: Container(
//                     width: size.width * 0.8,
//                     height: size.width * 0.8,
//                     decoration: BoxDecoration(
//                       gradient: RadialGradient(
//                         colors: [
//                           Colors.white.withOpacity(0.2),
//                           Colors.white.withOpacity(0.0),
//                         ],
//                         stops: const [0.0, 1.0],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           Positioned(
//             bottom: -size.width * 0.6,
//             left: -size.width * 0.3,
//             child: AnimatedBuilder(
//               animation: _animationController,
//               builder: (context, child) {
//                 return Transform.rotate(
//                   angle: -_animationController.value * 0.2,
//                   child: Container(
//                     width: size.width * 0.9,
//                     height: size.width * 0.9,
//                     decoration: BoxDecoration(
//                       gradient: RadialGradient(
//                         colors: [
//                           Colors.white.withOpacity(0.15),
//                           Colors.white.withOpacity(0.0),
//                         ],
//                         stops: const [0.0, 1.0],
//                       ),
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Wave effect at bottom
//           // Positioned(
//           //   bottom: 0,
//           //   left: 0,
//           //   right: 0,
//           //   // child: AnimatedBuilder(
//           //   //   animation: _animationController,
//           //   //   // builder: (context, _) {
//           //   //   //   return CustomPaint(
//           //   //   //     size: Size(size.width, 120),
//           //   //   //   //   painter: WavePainter(
//           //   //   //   //     animationValue: _animationController.value,
//           //   //   //   //     isDarkMode: isDarkMode,
//           //   //   //   //   ),
//           //   //   //   // );
//           //   //   // },
//           //   // ),
//           // ),

//           // Main content with animations
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Animated Logo with reflection
//                 AnimatedBuilder(
//                   animation: _animationController,
//                   builder: (context, child) {
//                     return Opacity(
//                       opacity: _fadeAnimation.value,
//                       child: Transform.scale(
//                         scale: _scaleAnimation.value,
//                         child: Transform.rotate(
//                           angle: _rotationAnimation.value,
//                           child: child,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Column(
//                     children: [
//                       // Logo - Shadow removed
//                       Container(
//                         width: 180,
//                         height: 180,
//                         decoration: const BoxDecoration(
//                           shape: BoxShape.circle,
//                           // Shadow removed
//                         ),
//                         child: ClipOval(
//                           child: Image.asset(
//                             'assets/images/logo.png',
//                             width: 180,
//                             height: 180,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),

//                       // Reflection effect
//                       // Container(
//                       //   height: 20,
//                       //   width: 140,
//                       //   margin: const EdgeInsets.only(top: 10),
//                       // decoration: BoxDecoration(
//                       // gradient: LinearGradient(
//                       //   begin: Alignment.topCenter,
//                       //   end: Alignment.bottomCenter,
//                       // colors: [
//                       //   const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
//                       //   Colors.white.withOpacity(0.0),
//                       // ],
//                       // ),
//                       //   borderRadius: BorderRadius.circular(100),
//                       // ),
//                       // ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // Modern loading indicator
//                 AnimatedBuilder(
//                   animation: _animationController,
//                   builder: (context, _) {
//                     return Opacity(
//                       opacity: _fadeAnimation.value,
//                       child: Container(
//                         width: 60,
//                         height: 60,
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.15),
//                           borderRadius: BorderRadius.circular(30),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 10,
//                               spreadRadius: -5,
//                             ),
//                           ],
//                         ),
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.white.withOpacity(0.9)),

//                           strokeWidth: 3,
//                         ),
//                       ),
//                     );
//                   },
//                 ),

//                 const SizedBox(height: 30),

//                 // App name with animated slide
//                 AnimatedBuilder(
//                   animation: _animationController,
//                   builder: (context, child) {
//                     return Opacity(
//                       opacity: _fadeAnimation.value,
//                       child: Transform.translate(
//                         offset: Offset(0, _slideAnimation.value),
//                         child: child,
//                       ),
//                     );
//                   },
//                   child: Column(
//                     children: [
//                       // App name with glass effect
//                       // ClipRRect(
//                       //   borderRadius: BorderRadius.circular(20),
//                       //   child: BackdropFilter(
//                       //     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                       //     child: Container(
//                       //       padding: const EdgeInsets.symmetric(
//                       //         horizontal: 30,
//                       //         vertical: 12,
//                       //       ),
//                       //       decoration: BoxDecoration(
//                       //         color: Colors.white.withOpacity(0.15),
//                       //         borderRadius: BorderRadius.circular(20),
//                       //         border: Border.all(
//                       //           color: Colors.white.withOpacity(0.2),
//                       //           width: 1.5,
//                       //         ),
//                       //       ),
//                       //       child: const Text(
//                       //         "We Neighbour",
//                       //         style: TextStyle(
//                       //           color: Colors.white,
//                       //           fontSize: 32,
//                       //           fontWeight: FontWeight.bold,
//                       //           letterSpacing: 1.2,
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ),
//                       // ),

//                       const SizedBox(height: 15),

//                       // Tagline with animated typing effect
//                       SizedBox(
//                         height: 20,
//                         child: AnimatedBuilder(
//                           animation: _animationController,
//                           builder: (context, _) {
//                             const String fullText =
//                                 "Connecting Communities · Simplifying Life";
//                             final int textLength =
//                                 (fullText.length * _animationController.value)
//                                     .round();
//                             final String visibleText = fullText.substring(
//                                 0, textLength.clamp(0, fullText.length));

//                             return Text(
//                               visibleText,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w400,
//                                 letterSpacing: 0.5,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Version number at bottom
//           Positioned(
//             bottom: 30,
//             left: 0,
//             right: 0,
//             child: AnimatedBuilder(
//               animation: _animationController,
//               builder: (context, _) {
//                 return Opacity(
//                   opacity: _fadeAnimation.value,
//                   child: const Text(
//                     "Version 1.0.0",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Custom wave painter for bottom wave effect
// // class WavePainter extends CustomPainter {
// //   final double animationValue;
// //   final bool isDarkMode;

// //   WavePainter({required this.animationValue, required this.isDarkMode});

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = Colors.white.withOpacity(0.1)
// //       ..style = PaintingStyle.fill;

// //     final path = Path();
// //     final width = size.width;
// //     final height = size.height;

// //     path.moveTo(0, height);

// //     for (int i = 0; i < width; i++) {
// //       final x = i.toDouble();
// //       final sinValue = math.sin((x / width * 4 * math.pi) + (animationValue * math.pi * 2));
// //       final y = height - (height * 0.5) - (sinValue * 10);
// //       path.lineTo(x, y);
// //     }

// //     path.lineTo(width, height);
// //     path.close();

// //     canvas.drawPath(path, paint);

// //     // Second wave with different phase
// //     final paint2 = Paint()
// //       ..color = Colors.white.withOpacity(0.15)
// //       ..style = PaintingStyle.fill;

// //     final path2 = Path();
// //     path2.moveTo(0, height);

// //     for (int i = 0; i < width; i++) {
// //       final x = i.toDouble();
// //       final sinValue = math.sin((x / width * 3 * math.pi) + (animationValue * math.pi * 2) + math.pi / 2);
// //       final y = height - (height * 0.3) - (sinValue * 8);
// //       path2.lineTo(x, y);
// //     }

// //     path2.lineTo(width, height);
// //     path2.close();

// //     canvas.drawPath(path2, paint2);
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // }