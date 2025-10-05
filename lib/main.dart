// lib/main.dart

import 'package:chibipdf/screens/home_screen.dart';
import 'package:chibipdf/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdfrx/pdfrx.dart';

void main() {
  // Required to set up Flutter bindings before initializing libraries
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize pdfrx (this replaces the old PdfJs.init())
  pdfrxFlutterInitialize();

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
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'ChibiPDF',
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            textTheme:
            GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme:
            GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          ),
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          home: const HomeScreen(),
        );
      },
    );
  }
}
