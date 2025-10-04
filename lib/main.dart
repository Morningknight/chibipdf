// lib/main.dart

import 'dart:io';
import 'package:chibipdf/about_screen.dart';
import 'package:chibipdf/pdf_viewer_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChibiPdfApp());
}

class ChibiPdfApp extends StatelessWidget {
  const ChibiPdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChibiPDF',
      // Theming our app for that "chibi" feel
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.deepPurple[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple[100],
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
      ),
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This function handles the logic for picking a PDF file
  Future<void> _pickAndOpenFile() async {
    try {
      // Use the file_picker to open the device's file explorer
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'], // We only want to allow PDFs
      );

      // If the user doesn't pick a file, result will be null
      if (result == null || result.files.single.path == null) return;

      // Get the file from the result
      final file = File(result.files.single.path!);

      // Navigate to our PDF Viewer screen, passing the file to it
      if (mounted) { // A best-practice check
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(file: file),
          ),
        );
      }
    } catch (e) {
      // Handle potential errors, e.g., permissions denied
      debugPrint("Error picking file: $e");
      // You could show a snackbar here to inform the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChibiPDF'),
        actions: [
          // This is the button to open the About & Support screen
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      // The body of our home screen
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_rounded, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Tap the + button to open a PDF file.',
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            // We will add the 'Recents' and 'Favorites' list here later
          ],
        ),
      ),
      // This is the main button to open files
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndOpenFile,
        label: const Text('Open PDF'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }
}