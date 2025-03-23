// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class EntranceVerificationScreen extends StatefulWidget {
//   const EntranceVerificationScreen({super.key});

//   @override
//   State<EntranceVerificationScreen> createState() => _EntranceVerificationScreenState();
// }

// class _EntranceVerificationScreenState extends State<EntranceVerificationScreen> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   Barcode? result;
//   QRViewController? controller;
//   Map<String, dynamic>? visitorData;
//   bool isLoading = false;
//   static const String baseUrl = 'https://we-neighbour-backend.vercel.app';

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) async {
//       if (result != null) return; // Prevent multiple scans
//       setState(() {
//         result = scanData;
//         visitorData = jsonDecode(scanData.code!);
//       });
//       controller.pauseCamera();
//     });
//   }

//   Future<void> updateVisitorStatus(String action) async {
//     setState(() => isLoading = true);
//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/visitor/update-status'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'visitorId': visitorData!['visitorId'],
//           'action': action,
//         }),
//       ).timeout(const Duration(seconds: 10));

//       print('Update status response: ${response.statusCode} - ${response.body}');
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'])),
//         );
//         setState(() {
//           visitorData = null;
//           result = null;
//         });
//         controller?.resumeCamera();
//       } else {
//         throw Exception('Failed to update status: ${response.body}');
//       }
//     } catch (e) {
//       print('Error updating status: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Scan Visitor QR',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: Colors.blueAccent,
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           QRView(
//             key: qrKey,
//             onQRViewCreated: _onQRViewCreated,
//             overlay: QrScannerOverlayShape(
//               borderColor: Colors.blueAccent,
//               borderRadius: 10,
//               borderLength: 30,
//               borderWidth: 10,
//               cutOutSize: 300,
//             ),
//           ),
//           if (visitorData != null && !isLoading)
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.5),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       'Visitor Details',
//                       style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       'Number of Visitors: ${visitorData!['numOfVisitors']}',
//                       style: const TextStyle(fontSize: 16, color: Colors.black54),
//                     ),
//                     const SizedBox(height: 20),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () => updateVisitorStatus('accept'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blueAccent,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           ),
//                           child: const Text('Approve', style: TextStyle(color: Colors.white)),
//                         ),
//                         ElevatedButton(
//                           onPressed: () => updateVisitorStatus('reject'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           ),
//                           child: const Text('Decline', style: TextStyle(color: Colors.white)),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           if (isLoading)
//             const Center(
//               child: CircularProgressIndicator(color: Colors.blueAccent),
//             ),
//         ],
//       ),
//     );
//   }
// }