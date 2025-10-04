// lib/screens/image_to_pdf_screen.dart

import 'dart:io';
import 'package:chibipdf/screens/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ImageToPdfScreen extends StatefulWidget {
  // We accept a function to update the recents list on the home screen
  final Function(String) onPdfCreated;

  const ImageToPdfScreen({super.key, required this.onPdfCreated});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  bool _isCreatingPdf = false;

  // --- LOGIC: Select images from gallery ---
  Future<void> _selectImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  // --- LOGIC: Create and save the PDF ---
  Future<void> _createPdf() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image.')),
      );
      return;
    }

    setState(() {
      _isCreatingPdf = true; // Show loading indicator
    });

    try {
      final pdf = pw.Document();
      for (var imageFile in _selectedImages) {
        final image = pw.MemoryImage(imageFile.readAsBytesSync());
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(image));
            },
          ),
        );
      }

      // Get a path to save the file
      final outputDir = await getApplicationDocumentsDirectory();
      final fileName = 'ChibiPDF_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${outputDir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // --- Success ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF created successfully at ${file.path}')),
      );

      // Call the callback to update recents on the home screen
      widget.onPdfCreated(file.path);

      // Open the newly created PDF
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(file: file),
        ),
      );

    } catch (e) {
      // --- Error ---
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create PDF: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingPdf = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create PDF from Images'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedImages.isEmpty
                ? Center(
              child: Text(
                'Select images to get started.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : // Use ReorderableListView to allow users to change image order
            ReorderableListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                final image = _selectedImages[index];
                return Card(
                  key: ValueKey(image.path), // Important for reordering
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.file(image, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text('Image ${index + 1}'),
                    subtitle: Text(image.path.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedImages.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _selectedImages.removeAt(oldIndex);
                  _selectedImages.insert(newIndex, item);
                });
              },
            ),
          ),
          // --- BOTTOM ACTION BAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Images'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_selectedImages.isEmpty || _isCreatingPdf) ? null : _createPdf,
                    icon: _isCreatingPdf
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.picture_as_pdf),
                    label: const Text('Create PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}