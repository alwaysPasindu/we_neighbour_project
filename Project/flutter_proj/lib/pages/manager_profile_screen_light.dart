// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';

// class ManagerProfileScreenLight extends StatelessWidget {
//   const ManagerProfileScreenLight({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.black),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                 child: Column(
//                   children: [
//                     Stack(
//                       children: [
//                         const CircleAvatar(
//                           radius: 50,
//                           backgroundColor: AppTheme.accentColor,
//                           child: Icon(Icons.person, size: 60, color: Colors.white),
//                         ),
//                         Positioned(
//                           right: 0,
//                           bottom: 0,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: AppTheme.accentColor,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.camera_alt,
//                               size: 20,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'John Doe',
//                       style: AppTheme.titleStyle.copyWith(color: Colors.black),
//                     ),
//                     const SizedBox(height: 32),
//                     _buildInfoField('Email', 'johndoe@gmail.com'),
//                     _buildInfoField('Phone Number', '+94 71 234 3465'),
//                     _buildInfoField('Apartment', '2/3 Lotus Residence Colombo 03'),
//                     const Spacer(),
//                     _buildOption(
//                       'Settings',
//                       Icons.settings,
//                       onTap: () {
//                         Navigator.pushNamed(context, '/settings');
//                       },
//                     ),
//                     const SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoField(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.grey,
//             fontSize: 16,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 16,
//           ),
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(vertical: 12),
//           child: Divider(color: Colors.grey),
//         ),
//       ],
//     );
//   }

//   Widget _buildOption(String title, IconData icon, {required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: AppTheme.primaryColor),
//             const SizedBox(width: 12),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.black,
//                 fontSize: 16,
//               ),
//             ),
//             const Spacer(),
//             const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }

