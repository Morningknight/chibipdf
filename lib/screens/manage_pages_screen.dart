// lib/screens/manage_pages_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

// A helper class to hold page data
class PageData {
  final PdfPage page;
  final int originalIndex;

  PageData(this.page, this.originalIndex);
}

class ManagePagesScreen extends StatefulWidget {
  final String filePath;
  const ManagePagesScreen({super.key, required this.filePath});

  @override
  State<ManagePagesScreen> createState() => _ManagePagesScreenState();
}

class _ManagePagesScreenState extends State<ManagePagesScreen> {
  PdfDocument? _document;
  List<PageData> _pages = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final doc = await PdfDocument.openFile(widget.filePath);
      final pageList = <PageData>[];
      for (int i = 0; i < doc.pages.length; i++) {
        final page = doc.pages[i];
        pageList.add(PageData(page, i));
      }
      setState(() {
        _document = doc;
        _pages = pageList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading PDF for editing: $e");
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: $e')),
        );
      }
    }
  }

  Future<void> _savePdf() async {
    if (_pages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty PDF.')),
      );
      return;
    }

    setState(() { _isSaving = true; });

    try {
      final newPdf = pw.Document();

      for (final pageData in _pages) {
        final pageImage = await pageData.page.render();
        if (pageImage == null) continue;
        final imageProvider = pw.MemoryImage(pageImage.pixels);

        newPdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(child: pw.Image(imageProvider));
            },
          ),
        );
      }

      final originalFile = File(widget.filePath);
      final dir = await getApplicationDocumentsDirectory();
      final newFileName = '${originalFile.path.split(Platform.pathSeparator).last.replaceAll('.pdf', '')}_edited.pdf';
      final newFile = File('${dir.path}/$newFileName');
      await newFile.writeAsBytes(await newPdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved successfully to $newFileName')),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      debugPrint("Error saving PDF: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save PDF: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Pages'),
        actions: [
          TextButton.icon(
            icon: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                : const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: (_isSaving || _isLoading) ? null : _savePdf,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _document == null
          ? const Center(child: Text('Could not load PDF.'))
          : ReorderableGridView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _pages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2 / 3,
        ),
        itemBuilder: (context, index) {
          final pageData = _pages[index];
          return Card(
            key: ValueKey(pageData.originalIndex),
            elevation: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // =========== THIS IS THE FINAL, ROBUST FIX ===========
                FutureBuilder<PdfImage?>(
                  future: pageData.page.render(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Icon(Icons.error_outline, color: Colors.red));
                    }
                    // Use Flutter's built-in Image.memory to display the rendered page bytes
                    return Image.memory(snapshot.data!.pixels, fit: BoxFit.contain);
                  },
                ),
                // ======================================================
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _pages.removeAt(index);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                )
              ],
            ),
          );
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final item = _pages.removeAt(oldIndex);
            _pages.insert(newIndex, item);
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _document?.dispose();
    super.dispose();
  }
}