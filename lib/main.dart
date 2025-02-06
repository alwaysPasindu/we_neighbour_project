import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'screens/login_page.dart';
=======
import 'screens/resident_home_page.dart';
>>>>>>> 1a42624737af69eebe041baaa5bb19f5f5d8902b

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
<<<<<<< HEAD
  const MyApp({super.key});
=======
  const MyApp({Key? key}) : super(key: key);
>>>>>>> 1a42624737af69eebe041baaa5bb19f5f5d8902b

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
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
=======
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
>>>>>>> 1a42624737af69eebe041baaa5bb19f5f5d8902b
