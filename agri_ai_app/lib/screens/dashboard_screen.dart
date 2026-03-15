import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _isPredicting = false;
  String? _errorMessage;

  String _userName = "Farmer";
  int _totalScans = 0;
  double? _healthRatio;
  int _recentAlerts = 0;

  List<Map<String, dynamic>> _recentScans = [];

  File? _selectedImage;
  String? _predictionError;
  Map<String, dynamic>? _predictionResult;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final results = await Future.wait([
        ApiService.authenticatedGet('dashboard/'),
        ApiService.authenticatedGet('recent-scans/'),
      ]);

      final dashboard = jsonDecode(results[0].body);
      final scans = jsonDecode(results[1].body);

      if (mounted) {
        setState(() {
          _userName = dashboard['user']?.toString() ?? "Farmer";
          _totalScans = (dashboard['total_scans'] as num?)?.toInt() ?? 0;
          _healthRatio = (dashboard['health_ratio'] as num?)?.toDouble();
          _recentAlerts = (dashboard['alerts'] as num?)?.toInt() ?? 0;
          _recentScans = List<Map<String, dynamic>>.from(scans);
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to load dashboard. Check connection.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndPredict(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (file == null || !mounted) return;

      setState(() {
        _selectedImage = File(file.path);
        _predictionResult = null;
        _predictionError = null;
        _isPredicting = true;
      });

      final token = await ApiService.getToken();
      if (token == null) {
        setState(() => _predictionError = "Session expired. Please log in.");
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}scan/'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 201 && mounted) {
        final data = jsonDecode(response.body);
        setState(() => _predictionResult = data);
        _loadDashboardData(); // background refresh
      } else if (response.statusCode == 401 && mounted) {
        await ApiService.logout();
        Navigator.pushReplacementNamed(context, '/login');
      } else if (mounted) {
        setState(() {
          _predictionError = jsonDecode(response.body)['error'] ?? 'Diagnosis failed';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _predictionError = "Error: ${e.toString().split('\n')[0]}");
      }
    } finally {
      if (mounted) setState(() => _isPredicting = false);
    }
  }

  Map<String, dynamic>? get _latest => _predictionResult ?? (_recentScans.isNotEmpty ? _recentScans.first : null);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _LoadingView();
    if (_errorMessage != null) {
      return _ErrorView(message: _errorMessage!, onRetry: _loadDashboardData);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final healthColor = _healthRatio == null
        ? Colors.grey
        : _healthRatio! >= 85
            ? Colors.green
            : _healthRatio! >= 60
                ? Colors.orange
                : Colors.red;

    final alertColor = _recentAlerts > 0 ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF8FAF8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (_) => _ScanBottomSheet(
            onGallery: () => _pickAndPredict(ImageSource.gallery),
            onCamera: () => _pickAndPredict(ImageSource.camera),
            isPredicting: _isPredicting,
          ),
        ),
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('Scan Crop'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text('Agri AI'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      drawer: _buildSimplifiedDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: Colors.green.shade700,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Urgency banner (only when alerts exist)
            if (_recentAlerts > 0)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade700, Colors.red.shade900],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '$_recentAlerts crop issues need attention',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70),
                    ],
                  ),
                ),
              ),

            
            // Compact KPI pills – horizontal scroll
SliverPadding(
  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
  sliver: SliverToBoxAdapter(
    child: SizedBox(
      height: 125, // increased from 108 to give breathing room
      child: Align(
        alignment: Alignment.centerLeft,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(width: 9),
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return _KpiPill(
                  label: 'Scans',
                  value: '$_totalScans',
                  color: Colors.green.shade700,
                  icon: Icons.analytics_rounded,
                );
              case 1:
                return _KpiPill(
                  label: 'Alerts',
                  value: '$_recentAlerts',
                  color: alertColor,
                  icon: Icons.notifications_active_rounded,
                );
              case 2:
                return _KpiPill(
                  label: 'Health',
                  value: _healthRatio != null
                      ? '${_healthRatio!.toStringAsFixed(0)}%'
                      : '—',
                  color: healthColor,
                  icon: Icons.eco_rounded,
                  subtitle: _healthRatio != null
                      ? _healthRatio! >= 85
                          ? 'Good'
                          : 'Watch'
                      : null,
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    ),
  ),
),

            // Latest Diagnosis – hero section after scan
            if (_latest != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: _DiagnosisHero(result: _latest!),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.eco_outlined, size: 80, color: Colors.green.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No scans yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button below to start',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 140)), // space for FAB
          ],
        ),
      ),
    );
  }

  Drawer _buildSimplifiedDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.green.shade600],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.agriculture_rounded, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text('Agri AI', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Crop Health Assistant', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('Scan History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/analytics');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
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

    if (ok == true && context.mounted) {
      await ApiService.logout();
      if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }
}

// ────────────────────────────────────────────────
// New compact widgets
// ────────────────────────────────────────────────

class _KpiPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final String? subtitle;

  const _KpiPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: color.withOpacity(0.9)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: TextStyle(fontSize: 12, color: color)),
          ],
        ],
      ),
    );
  }
}

class _ScanBottomSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final bool isPredicting;

  const _ScanBottomSheet({
    required this.onGallery,
    required this.onCamera,
    required this.isPredicting,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Scan Crop',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take or upload a photo of the affected leaf',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ScanOptionButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: onGallery,
                ),
                _ScanOptionButton(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: onCamera,
                ),
              ],
            ),
            if (isPredicting) ...[
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Analyzing image...', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ScanOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.green.shade100,
              child: Icon(icon, size: 36, color: Colors.green.shade800),
            ),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DiagnosisHero extends StatelessWidget {
  final Map<String, dynamic> result;

  const _DiagnosisHero({required this.result});

  @override
  Widget build(BuildContext context) {
    final disease = result['disease']?.toString() ?? 'Unknown';
    final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;
    final rec = result['recommendation'] as Map<String, dynamic>?;

    final isHighConf = confidence >= 85;
    final color = isHighConf ? Colors.green : Colors.orange;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result['image'] != null)
            Image.network(
              'http://199.231.191.165:8000${result['image']}',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        disease,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
                      ),
                    ),
                    Chip(
                      label: Text(isHighConf ? 'HIGH CONFIDENCE' : 'Detected'),
                      backgroundColor: color.withOpacity(0.15),
                      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${confidence.toStringAsFixed(1)}% confidence',
                  style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                if (rec != null) ...[
                  const Text('What to do now', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(rec['treatment']?.toString() ?? '—', style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 20),
                  const Text('Prevention tips', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(rec['prevention']?.toString() ?? '—', style: const TextStyle(height: 1.5)),
                ] else ...[
                  const Text('Loading recommendations...', style: TextStyle(color: Colors.grey)),
                ],

                const SizedBox(height: 24),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Scan Again'),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => _ScanBottomSheet(
                          onGallery: () {},
                          onCamera: () {},
                          isPredicting: false,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green.shade700),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('History'),
                      onPressed: () => Navigator.pushNamed(context, '/history'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your existing _LoadingView and _ErrorView or use these simplified ones
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 24),
            Text('Loading farm dashboard…'),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 80, color: Colors.red),
            const SizedBox(height: 24),

            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Retry button
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
              ),
              onPressed: onRetry,
            ),

            const SizedBox(height: 16),

            // Login button
            OutlinedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Go to Login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade700),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}