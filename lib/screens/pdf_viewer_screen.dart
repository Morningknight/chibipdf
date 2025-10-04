// lib/screens/pdf_viewer_screen.dart

import 'dart:io';
import 'package:chibipdf/screens/manage_pages_screen.dart'; // Import the new screen
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatelessWidget {
  final File file;

  const PdfViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.path.split(Platform.pathSeparator).last),
        actions: [
          // --- THIS IS THE NEW BUTTON ---
          IconButton(
            icon: const Icon(Icons.edit_document),
            tooltip: 'Manage Pages',
            onPressed: () {
              // Navigate to the new screen, passing the file path
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManagePagesScreen(filePath: file.path),
                ),
              );
            },
          ),
          // -----------------------------
        ],
      ),
      body: PDFView(
        filePath: file.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: false,
      ),
    );
  }
}