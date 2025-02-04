import 'package:flutter/material.dart';
import 'screens/resident_home_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'WE NEIGHBOUR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E88FF),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: const ResidentHomePage(),
    );
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "app demo",
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text("Good Morning, Pasindu!"),
//           backgroundColor: Colors.amberAccent,
//         ),
//       ),
//     );
//   }
// }

      title: 'We Neighbour',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Make sure you have this font in your assets or use a different one
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

