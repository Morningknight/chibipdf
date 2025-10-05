// lib/screens/manage_pages_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfrx/pdfrx.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

enum PageType { existing, newImage }

class EditablePage {
  final PageType type;
  final dynamic data;
  final int id;

  EditablePage({required this.type, required this.data, required this.id});
}

class ManagePagesScreen extends StatefulWidget {
  final String filePath;
  const ManagePagesScreen({super.key, required this.filePath});

  @override
  State<ManagePagesScreen> createState() => _ManagePagesScreenState();
}

class _ManagePagesScreenState extends State<ManagePagesScreen> {
  PdfDocument? _document;
  List<EditablePage> _pages = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      final doc = await PdfDocument.openFile(widget.filePath);
      final pageList = <EditablePage>[];
      for (int i = 0; i < doc.pages.length; i++) {
        pageList.add(EditablePage(
          type: PageType.existing,
          data: doc.pages[i],
          id: _nextId++,
        ));
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

  Future<void> _addPagesFromImages() async {
    final picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final newPages = pickedFiles.map((file) {
        return EditablePage(
          type: PageType.newImage,
          data: File(file.path),
          id: _nextId++,
        );
      }).toList();
      setState(() {
        _pages.addAll(newPages);
      });
    }
  }

  // =========== THIS IS THE CORRECTED FUNCTION ===========
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

      for (final page in _pages) {
        // We create a generic 'pageWidget' to hold the final image.
        pw.Widget pageWidget;

        if (page.type == PageType.existing) {
          final pageImage = await (page.data as PdfPage).render();
          if (pageImage == null) continue;

          // Use pw.RawImage for the uncompressed pixel data
          pageWidget = pw.Image(
            pw.RawImage(
              bytes: pageImage.pixels,
              width: pageImage.width,
              height: pageImage.height,
            ),
          );
        } else {
          // Use pw.MemoryImage for the already-encoded file data
          final imageProvider = pw.MemoryImage((page.data as File).readAsBytesSync());
          pageWidget = pw.Image(imageProvider);
        }

        newPdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(child: pageWidget);
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
        // We pop twice to go back to the home screen, not just the viewer
        Navigator.of(context).pop();
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
      if (mounted) { setState(() { _isSaving = false; }); }
    }
  }
  // =======================================================


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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPagesFromImages,
        label: const Text('Add Pages'),
        icon: const Icon(Icons.add_photo_alternate),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _document == null
          ? const Center(child: Text('Could not load PDF.'))
          : ReorderableGridView.builder(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0),
        itemCount: _pages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2 / 3,
        ),
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Card(
            key: ValueKey(page.id),
            elevation: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (page.type == PageType.existing)
                  PdfPageView(
                    document: _document!,
                    pageNumber: (page.data as PdfPage).pageNumber,
                  )
                else
                  Image.file(page.data as File, fit: BoxFit.cover),
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