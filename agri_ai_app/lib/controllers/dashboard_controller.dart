// lib/controllers/dashboard_controller.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';   // ← Add this line (for TimeoutException)

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  // Weather Data
  Map<String, dynamic> weatherData = {
    'temperature': '--',
    'condition': 'Loading weather...',
    'humidity': '--',
    'windSpeed': '--',
    'city': 'Your Location',
  };

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
    _fetchWeather();
  }

  void dispose() {
    // cleanup if needed
  }

  Map<String, dynamic>? get latestScan => 
      predictionResult ?? (recentScans.isNotEmpty ? recentScans.first : null);

  // ── Load Dashboard ─────────────────────────────────────
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
      print('Dashboard load error: $e');
    } finally {
      isLoading = false;
      _notify();
    }
  }

  // ── Weather (kept simple) ──────────────────────────────
  Future<void> _fetchWeather() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        weatherData['condition'] = 'Location access denied';
        _notify();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

      String city = "Maseno";
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        city = placemarks.first.locality ?? "Maseno";
      } catch (_) {}

      const String apiKey = "f0009fd55a1ace1d68a7065d1e5082d4";

      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?'
        'lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = (data['main']['temp'] as num).round();
        final condition = data['weather'][0]['main'] as String;
        final humidity = data['main']['humidity'];

        weatherData = {
          'temperature': '$temp°',
          'condition': condition,
          'humidity': '$humidity%',
          'windSpeed': '${(data['wind']['speed'] as num).round()} km/h',
          'city': city,
        };
      } else {
        weatherData['condition'] = 'Weather unavailable';
      }
    } catch (e) {
      weatherData['condition'] = 'Weather unavailable';
      print('Weather error: $e');
    } finally {
      _notify();
    }
  }

 
 


 Future<void> pickAndPredict(ImageSource source) async {
  try {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 70,        // Reduced for better stability
      maxWidth: 800,
      maxHeight: 800,
    );

    if (file == null) return;

    final selectedImage = File(file.path);

    isPredicting = true;
    predictionResult = null;
    errorMessage = null;
    _notify();

    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      errorMessage = "Session expired. Please log in.";
      _notify();
      return;
    }

    final uri = Uri.parse('${ApiService.baseUrl}predict/');   // Note: you changed to /scan/ from /predict/

    var request = http.MultipartRequest('POST', uri);

    // More reliable header setting
    request.headers.addAll({
      'Authorization': 'Bearer ${token.trim()}',   // ← Changed from 'Bearer' to 'Token'
      'Accept': 'application/json',
    });

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      selectedImage.path,
      filename: 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
    ));

    print("=== UPLOADING IMAGE ===");
    print("URL: $uri");
    print("Authorization: Token ${token.substring(0, 25)}...");

    final streamed = await request.send().timeout(
      const Duration(seconds: 60),
    );

    final response = await http.Response.fromStream(streamed);

    print("Upload Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      predictionResult = data;
      await loadDashboardData(); // refresh stats
    } else if (response.statusCode == 401) {
      print("401 - Token was rejected");
      errorMessage = "Authentication failed. Please log in again.";
      await ApiService.logout();
      onNavigateToLogin();
    } else {
      String msg = 'Diagnosis failed (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        msg = body['detail'] ?? body['error'] ?? msg;
      } catch (_) {}
      errorMessage = msg;
    }
  } catch (e, stack) {
    print("PickAndPredict error: $e");
    print("Stack: $stack");
    errorMessage = "Upload failed: ${e.toString().split('\n')[0]}";
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
      //await ApiService.logout();
      //onNavigateToLogin();
    }
  }

  void _notify() {
    onStateUpdate();
  }
}