import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

class DashboardController {
  // ── State ───────────────────────────────────────────────
  bool isLoading = true;
  bool isPredicting = false;
  String? errorMessage;

  String userName = "Farmer";
  int totalScans = 0;
  double? healthRatio;
  int recentAlerts = 0;

  List<Map<String, dynamic>> recentScans = [];
  Map<String, dynamic>? predictionResult;

  // ── Callbacks ───────────────────────────────────────────
  final VoidCallback onStateUpdate;
  final VoidCallback onNavigateToLogin;
  final void Function(String route) onNavigateTo;

  DashboardController({
    required this.onStateUpdate,
    required this.onNavigateToLogin,
    required this.onNavigateTo,
  });

  void init() {
    loadDashboardData();
  }

  void dispose() {
    // clean up if needed (streams, timers, etc.)
  }

  Map<String, dynamic>? get latestScan => predictionResult ?? (recentScans.isNotEmpty ? recentScans.first : null);

  Future<void> loadDashboardData() async {
    isLoading = true;
    errorMessage = null;
    _notify();

    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        onNavigateToLogin();
        return;
      }

      final results = await Future.wait([
        ApiService.authenticatedGet('dashboard/'),
        ApiService.authenticatedGet('recent-scans/'),
      ]);

      final dashboard = jsonDecode(results[0].body);
      final scans = jsonDecode(results[1].body);

      userName = dashboard['user']?.toString() ?? "Farmer";
      totalScans = (dashboard['total_scans'] as num?)?.toInt() ?? 0;
      healthRatio = (dashboard['health_ratio'] as num?)?.toDouble();
      recentAlerts = (dashboard['alerts'] as num?)?.toInt() ?? 0;
      recentScans = List<Map<String, dynamic>>.from(scans);
    } catch (e) {
      errorMessage = 'Failed to load dashboard. Check connection.';
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<void> pickAndPredict(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (file == null) return;

      final selectedImage = File(file.path);

      isPredicting = true;
      predictionResult = null;
      errorMessage = null;
      _notify();

      final token = await ApiService.getToken();
      if (token == null) {
        errorMessage = "Session expired. Please log in.";
        _notify();
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}scan/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', selectedImage.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        predictionResult = data;
        await loadDashboardData(); // refresh stats
      } else if (response.statusCode == 401) {
        await ApiService.logout();
        onNavigateToLogin();
      } else {
        errorMessage = jsonDecode(response.body)['error'] ?? 'Diagnosis failed';
      }
    } catch (e) {
      errorMessage = "Error: ${e.toString().split('\n')[0]}";
    } finally {
      isPredicting = false;
      _notify();
    }
  }

  Future<void> confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Sign out of Agri AI?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ApiService.logout();
      onNavigateToLogin();
    }
  }

  void _notify() {
    onStateUpdate();
  }
}