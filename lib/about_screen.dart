// lib/about_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Helper function to launch a URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Could not launch the URL
      // In a real app, you might want to show a snackbar or dialog
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Support'),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ChibiPDF',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Small, Cute, Powerful.\nYour PDF buddy for all-nighters.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const Divider(height: 40),
            Text(
              'This app is, and always will be, completely free and ad-free. It\'s an offline-first tool built to respect your privacy and focus.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'If you find ChibiPDF helpful, please consider supporting its development. It helps me keep the app updated and running!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            // Donation Buttons
            _buildDonationButton(
              text: 'Buy Me a Coffee',
              icon: Icons.coffee,
              color: const Color(0xFFFFDD00),
              onPressed: () {
                // Replace with your actual Buy Me a Coffee link
                _launchURL('https://www.buymeacoffee.com/your-username');
              },
            ),
            const SizedBox(height: 12),
            _buildDonationButton(
              text: 'Support on Ko-fi',
              icon: Icons.favorite,
              color: const Color(0xFFF16061),
              onPressed: () {
                // Replace with your actual Ko-fi link
                _launchURL('https://ko-fi.com/your-username');
              },
            ),
            const SizedBox(height: 12),
            _buildDonationButton(
              text: 'Donate with PayPal',
              icon: Icons.paypal,
              color: const Color(0xFF00457C),
              onPressed: () {
                // Replace with your actual PayPal.me link
                _launchURL('https://paypal.me/your-username');
              },
            ),
          ],
        ),
      ),
    );
  }

  // A helper widget to create styled buttons to avoid repeating code
  Widget _buildDonationButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
    );
  }
}