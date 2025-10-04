// lib/screens/home_screen.dart

import 'dart:io'; // <--- THIS WAS THE MISSING LINE
import 'package:chibipdf/screens/image_to_pdf_screen.dart';
import 'package:chibipdf/screens/pdf_viewer_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE for Recents ---
  List<String> _recentFiles = [];
  static const String _recentsKey = 'recent_files';

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  // --- LOGIC for loading and saving recents ---
  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentFiles = prefs.getStringList(_recentsKey) ?? [];
    });
  }

  Future<void> _addAndSaveRecent(String path) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedRecents = List.from(_recentFiles);
    updatedRecents.remove(path);
    updatedRecents.insert(0, path);
    if (updatedRecents.length > 20) {
      updatedRecents = updatedRecents.sublist(0, 20);
    }
    await prefs.setStringList(_recentsKey, updatedRecents);
    setState(() {
      _recentFiles = updatedRecents;
    });
  }

  String _getFileName(String path) {
    // This now works because the 'Platform' class is available from 'dart:io'
    return path.substring(path.lastIndexOf(Platform.pathSeparator) + 1);
  }

  // --- LOGIC for picking files ---
  Future<void> _pickAndOpenFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.isEmpty) return;
      final String? filePath = result.files.first.path;
      if (filePath == null) return;

      // This now works because the 'File' class is available
      await _openPdf(File(filePath));
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> _openPdf(File file) async {
    if (!await file.exists()) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: File not found at ${file.path}')),
        );
      }
      return;
    }
    await _addAndSaveRecent(file.path);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(file: file),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<_ToolCard> tools = [
      _ToolCard(
        title: 'View PDF',
        icon: Icons.picture_as_pdf_rounded,
        color: Colors.deepPurple,
        action: (ctx) => _pickAndOpenFile(ctx),
      ),
      _ToolCard(
        title: 'Create from Images',
        icon: Icons.add_photo_alternate_rounded,
        color: Colors.orange,
        action: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageToPdfScreen(
                onPdfCreated: (path) {
                  _addAndSaveRecent(path);
                },
              ),
            ),
          );
        },
      ),
      _ToolCard(
        title: 'Merge PDFs',
        icon: Icons.merge_type_rounded,
        color: Colors.teal,
        action: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon!')),
          );
        },
      ),
      _ToolCard(
        title: 'Convert PDF',
        icon: Icons.transform_rounded,
        color: Colors.pink,
        action: (context) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon!')),
          );
        },
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            centerTitle: false,
            expandedHeight: 180.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                'ChibiPDF',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                "What do you need to do?",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              childCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return _buildToolCard(context, tool);
              },
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                "Recently Opened",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _recentFiles.isEmpty
              ? SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "Opened PDFs will appear here.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final filePath = _recentFiles[index];
                final file = File(filePath);

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(
                      _getFileName(filePath),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      filePath,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openPdf(file),
                  ),
                );
              },
              childCount: _recentFiles.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolCard tool) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => tool.action(context),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(tool.icon, size: 40, color: tool.color),
              const SizedBox(height: 12),
              Text(
                tool.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard {
  final String title;
  final IconData icon;
  final Color color;
  final Function(BuildContext) action;

  _ToolCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.action,
  });
}