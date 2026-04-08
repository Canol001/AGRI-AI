import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard/scan_bottom_sheet.dart';
import '../widgets/dashboard/diagnosis_hero.dart';
import '../widgets/dashboard/loading_view.dart';
import '../widgets/dashboard/error_view.dart';
import '../widgets/bottom_nav_bar.dart';   // ← Correct path
import '../widgets/dashboard/footer_note.dart';     // ← Correct path

import 'about_screen.dart';

import '../widgets/update_dialog.dart';
import '../services/update_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardController _controller;

  @override
  void initState() {
    super.initState();
    _checkUpdate();
    _controller = DashboardController(
      onStateUpdate: () => setState(() {}),
      onNavigateToLogin: () {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
      },
      onNavigateTo: (route) {
        if (mounted) Navigator.pushNamed(context, route);
      },
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



Future<void> _checkUpdate() async {
  final update = await UpdateService.checkForUpdate();

  if (update != null && mounted) {
    showUpdateDialog(context, update);
  }
}






  @override
  Widget build(BuildContext context) {
    // Loading State
    if (_controller.isLoading) {
      return const LoadingView();
    }

    // Error State - Only show login if truly unauthenticated
    if (_controller.errorMessage != null) {
      return ErrorView(
        message: _controller.errorMessage!,
        onRetry: _controller.loadDashboardData,
        // Removed showLoginButton - we'll handle login inside controller
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Color(0xFFF8F9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // make AppBar itself transparent
        elevation: 0,
        title: Text(
          "Agri AI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // white looks better on images
          ),
        ),
  actions: [
    IconButton(
      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
      onPressed: () {},
    ),
  ],
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: NetworkImage(
          "https://static.vecteezy.com/system/resources/previews/013/681/217/large_2x/abstract-elegant-dark-green-background-with-golden-line-diagonal-and-lighting-effect-sparkle-luxury-template-design-free-vector.jpg"
        ),
        fit: BoxFit.cover,
      ),
    ),
  ),
),

      bottomNavigationBar: BottomNavBar(
  currentIndex: 0,        // Dashboard is index 0
  onTap: (index) {
    switch (index) {
      case 0:
        // Already on Dashboard → do nothing
        break;

      case 1:
        // History
        Navigator.pushReplacementNamed(context, '/history');
        break;

      case 2:
        // Scan button - Open bottom sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ScanBottomSheet(
            onGallery: () => _controller.pickAndPredict(ImageSource.gallery),
            onCamera: () => _controller.pickAndPredict(ImageSource.camera),
            isPredicting: _controller.isPredicting,
          ),
        );
        break;

      case 4:
        // Settings
        Navigator.pushReplacementNamed(context, '/settings');
        break;

      case 5:
        // Profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  },
),

      body: RefreshIndicator(
        onRefresh: _controller.loadDashboardData,
        color: const Color(0xFF4CAF50),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              const Text(
                "Hello 👋",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                "Welcome, ${_controller.userName}!",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // Weather Card
              _buildWeatherCard(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(context),

              const SizedBox(height: 28),

              // Tip of the Day
              _buildTipOfTheDay(),

              const SizedBox(height: 28),

              // KPI Stats (Total Scans, Alerts, Health)
              _buildKpiSection(),

              const SizedBox(height: 28),

              // Latest Analysis
              const Text(
                "Latest Analysis",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (_controller.latestScan != null)
                DiagnosisHero(result: _controller.latestScan!)
              else
                _buildEmptyState(),

              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  // Weather Card with real data
Widget _buildWeatherCard() {
  final weather = _controller.weatherData;

  return Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
         Icon(
  _getWeatherIcon(weather['condition'] ?? ""),
  size: 52,
  color: const Color(0xFFFFC107),
),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather['city'] ?? "Your Location",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                
                Text(
                  "${weather['temperature']}C",
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w300, height: 1),
                ),
                Text(
                  weather['condition'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _weatherInfo(Icons.water_drop, "${weather['humidity']}"),
              const SizedBox(height: 12),
              _weatherInfo(Icons.air, "${weather['windSpeed']}"),
              const SizedBox(height: 12),
              _weatherInfo(Icons.cloud, "${weather['cloudiness']}"),
            ],
          ),
        ],
      ),
    ),
  );
}



IconData _getWeatherIcon(String condition) {
  final hour = DateTime.now().hour;

  final isNight = hour >= 18 || hour <= 6;

  condition = condition.toLowerCase();

  if (condition.contains("rain")) {
    return Icons.grain;
  }

  if (condition.contains("cloud")) {
    return Icons.cloud;
  }

  if (condition.contains("clear") || condition.contains("sun")) {
    return isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
  }

  if (condition.contains("storm")) {
    return Icons.thunderstorm;
  }

  if (condition.contains("mist") || condition.contains("fog")) {
    return Icons.blur_on;
  }

  return isNight ? Icons.nightlight_round : Icons.wb_cloudy;
}

Widget _weatherInfo(IconData icon, String value) {
  return Row(
    children: [
      Icon(icon, size: 18, color: Colors.grey.shade600),
      const SizedBox(width: 8),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    ],
  );
}


  // Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {"icon": Icons.menu_book, "label": "How to", "color": Colors.green},
      {"icon": Icons.camera_alt, "label": "About us", "color": Colors.purple},
      {"icon": Icons.camera_alt, "label": "Scan Crop", "color": Colors.orange},
      {"icon": Icons.trending_up, "label": "Market", "color": Colors.blue},
      {"icon": Icons.person_search, "label": "Ask Expert", "color": Colors.purple},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {
            if (action["label"] == "Scan Crop") {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ScanBottomSheet(
                  onGallery: () => _controller.pickAndPredict(ImageSource.gallery),
                  onCamera: () => _controller.pickAndPredict(ImageSource.camera),
                  isPredicting: _controller.isPredicting,
                ),
              );
            } else if (action["label"] == "About us") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutUsPage(),
                ),
              );
            } else {
              // Add navigation for other actions
            }
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: (action["color"] as Color).withOpacity(0.1),
                child: Icon(action["icon"] as IconData, color: action["color"] as Color, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                action["label"] as String,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Tip of the Day
  Widget _buildTipOfTheDay() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Color(0xFF4CAF50), size: 32),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tip of the Day",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                ),
                SizedBox(height: 6),
                Text(
                  "Water your crops early morning to reduce evaporation and help roots absorb nutrients more effectively.",
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const Icon(Icons.volume_up, color: Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  // KPI Section
  Widget _buildKpiSection() {
    return Row(
      children: [
        Expanded(
          child: _kpiCard("Total Scans", _controller.totalScans.toString(), Icons.analytics),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _kpiCard(
            "Active Alerts",
            _controller.recentAlerts.toString(),
            Icons.notifications_active,
            color: _controller.recentAlerts > 0 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _kpiCard(
            "Crop Health",
            _controller.healthRatio != null ? "${_controller.healthRatio!.toStringAsFixed(0)}%" : "—",
            Icons.eco,
            color: _controller.healthRatio != null && _controller.healthRatio! >= 85
                ? Colors.green
                : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _kpiCard(String title, String value, IconData icon, {Color? color}) {
    color ??= const Color(0xFF4CAF50);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.eco_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text("No scans yet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text("Tap 'Scan Crop' to get started", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}