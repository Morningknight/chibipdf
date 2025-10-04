// lib/screens/home_screen.dart

import 'dart:io';
import 'package:chibipdf/screens/pdf_viewer_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// This import is correct, but the code using it was wrong.
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- DATA FOR OUR TOOLS ---
  final List<_ToolCard> _tools = [
    _ToolCard(
      title: 'View PDF',
      icon: Icons.picture_as_pdf_rounded,
      color: Colors.deepPurple,
      action: (context) => _pickAndOpenFile(context),
    ),
    _ToolCard(
      title: 'Create from Images',
      icon: Icons.add_photo_alternate_rounded,
      color: Colors.orange,
      action: (context) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon!')),
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

  // --- LOGIC ---
  static Future<void> _pickAndOpenFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null || result.files.single.path == null) return;
      final file = File(result.files.single.path!);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfViewerScreen(file: file),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  // --- UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
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
                  color: Colors.black87,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade50],
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

          // The grid of tool buttons
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            // ================== THIS IS THE CORRECTED SECTION ==================
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2, // Two columns
              childCount: _tools.length,
              itemBuilder: (context, index) {
                final tool = _tools[index];
                return _buildToolCard(context, tool);
              },
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
            ),
            // ===================================================================
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