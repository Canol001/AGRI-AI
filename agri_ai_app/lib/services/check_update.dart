import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

Future<void> checkForUpdate(BuildContext context) async {
  try {
    // 1️⃣ Get current app version
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;

    // 2️⃣ Fetch latest version JSON
    final response = await http.get(
      Uri.parse('https://agri-ai-rust.vercel.app/latest_version.json'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String latestVersion = data['version'];

      // 3️⃣ Compare versions
      if (latestVersion != currentVersion) {
        // Show update prompt
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Available'),
            content: Text(
              'A new version ($latestVersion) is available. You have $currentVersion.\n\n${data['notes']}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              TextButton(
                onPressed: () {
                  // Open app store or web page for update
                  // Example: launch('https://play.google.com/store/apps/details?id=com.yourapp');
                },
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      }
    }
  } catch (e) {
    print('Version check failed: $e');
  }
}