// lib/main.dart

import 'package:chibipdf/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ChibiPdfApp());
}

class ChibiPdfApp extends StatelessWidget {
  const ChibiPdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChibiPDF',
      // We are updating the theme to be more modern and use our new font
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Set the default font for the entire app
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      // The app now starts directly at our new HomeScreen
      home: const HomeScreen(),
    );
  }
}