// lib/pdf_viewer_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatelessWidget {
  final File file;

  const PdfViewerScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.path.split('/').last), // Shows the file name
        backgroundColor: Colors.deepPurple[100],
      ),
      body: PDFView(
        filePath: file.path,
        // You can enable more options here if you want
        enableSwipe: true, // Allow changing pages with a swipe gesture
        swipeHorizontal: false, // Vertical scrolling
        autoSpacing: false,
        pageFling: false,
      ),
    );
  }
}