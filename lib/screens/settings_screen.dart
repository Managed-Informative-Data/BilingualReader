import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Contact & Feedback',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildContactTile(
            iconPath: 'assets/images/mail_logo.png',
            title: 'Email Us',
            subtitle: 'contact@managedinformativedata.com',
            onTap: () =>
                _launchUrl('mailto:contact@managedinformativedata.com'),
          ),
          const Divider(),
          _buildContactTile(
            iconPath: 'assets/images/linkedin_logo.png',
            title: 'Connect on LinkedIn',
            subtitle: 'Tristan Gerber',
            onTap: () => _launchUrl(
              'https://www.linkedin.com/in/tristan-gerber-8698b5231/',
            ),
          ),
          const Divider(),
          _buildContactTile(
            iconPath: 'assets/images/github_logo.png',
            title: 'Follow on GitHub',
            subtitle: 'Managed-Informative-Data',
            onTap: () =>
                _launchUrl('https://github.com/Managed-Informative-Data'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Image.asset(
        iconPath,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
