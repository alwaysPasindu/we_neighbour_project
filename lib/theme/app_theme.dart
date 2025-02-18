import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Define primary colors
  static const Color primaryColor = Color(0xFF12284C); // Dark blue
  static const Color accentColor = Color(0xFF4B7DFF);  // Light blue
  static const Color backgroundColor = Colors.white;

  // Text styles
  static final TextStyle titleStyle = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle bodyStyle = GoogleFonts.poppins(
    fontSize: 16,
    color: Colors.black,
  );
}

