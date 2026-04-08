import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String versionUrl =
      "https://agri-ai-rust.vercel.app/latest_version.json";

  static Future<Map<String, dynamic>?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(versionUrl));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final latestVersion = data["version"];

      if (_isNewerVersion(latestVersion, currentVersion)) {
        return data;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    List<int> latestParts = latest.split('.').map(int.parse).toList();
    List<int> currentParts = current.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }

    return false;
  }
}