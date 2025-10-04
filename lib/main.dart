// lib/main.dart

import 'package:chibipdf/screens/home_screen.dart';
import 'package:chibipdf/theme_notifier.dart'; // Import our new notifier
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import provider

void main() {
  // Wrap the entire app in our ThemeNotifier provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const ChibiPdfApp(),
    ),
  );
}

class ChibiPdfApp extends StatelessWidget {
  const ChibiPdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a Consumer widget to listen to theme changes
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'ChibiPDF',
          // Define our light theme
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
          ),
          // Define our dark theme
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          ),
          // Set the theme mode based on the notifier's state
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}