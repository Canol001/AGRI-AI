import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard/kpi_pill.dart';           // ← we'll update this widget
import '../widgets/dashboard/scan_bottom_sheet.dart';
import '../widgets/dashboard/diagnosis_hero.dart';
import '../widgets/dashboard/loading_view.dart';
import '../widgets/dashboard/error_view.dart';
import '../widgets/dashboard/dashboard_drawer.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) return const LoadingView();
    if (_controller.errorMessage != null) {
      return ErrorView(
        message: _controller.errorMessage!,
        onRetry: _controller.loadDashboardData,
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final healthColor = _controller.healthRatio == null
        ? Colors.grey.shade600
        : _controller.healthRatio! >= 85
            ? Colors.green.shade700
            : _controller.healthRatio! >= 60
                ? Colors.orange.shade700
                : Colors.red.shade700;

    final alertColor = _controller.recentAlerts > 0 ? Colors.red.shade700 : Colors.green.shade700;

    final latest = _controller.latestScan;

    return Scaffold(
      backgroundColor: isDark ? null : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Agri AI Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () => _controller.confirmLogout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const DashboardDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ScanBottomSheet(
            onGallery: () => _controller.pickAndPredict(ImageSource.gallery),
            onCamera: () => _controller.pickAndPredict(ImageSource.camera),
            isPredicting: _controller.isPredicting,
          ),
        ),
        label: const Text('New Scan'),
        icon: const Icon(Icons.camera_alt_rounded),
        backgroundColor: colorScheme.primary,
        elevation: 6,
        hoverElevation: 12,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: _controller.loadDashboardData,
        color: Colors.green.shade700,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Professional urgency banner (less aggressive)
            if (_controller.recentAlerts > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Card(
                    color: Colors.red.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 28),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Action Required',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_controller.recentAlerts} crop issue${_controller.recentAlerts > 1 ? 's' : ''} detected',
                                  style: TextStyle(color: Colors.red.shade800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // KPI Cards – modern card style instead of pills
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                ),
                delegate: SliverChildListDelegate([
                  _buildKpiCard(
                    title: 'Total Scans',
                    value: '${_controller.totalScans}',
                    icon: Icons.analytics_rounded,
                    color: Colors.green.shade700,
                  ),
                  _buildKpiCard(
                    title: 'Active Alerts',
                    value: '${_controller.recentAlerts}',
                    icon: Icons.notifications_active_rounded,
                    color: alertColor,
                  ),
                  _buildKpiCard(
                    title: 'Crop Health',
                    value: _controller.healthRatio != null
                        ? '${_controller.healthRatio!.toStringAsFixed(0)}%'
                        : '—',
                    subtitle: _controller.healthRatio != null
                        ? _controller.healthRatio! >= 85
                            ? 'Healthy'
                            : _controller.healthRatio! >= 60
                                ? 'Moderate'
                                : 'Critical'
                        : null,
                    icon: Icons.eco_rounded,
                    color: healthColor,
                  ),
                ]),
              ),
            ),

            // Latest Diagnosis Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Latest Analysis',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (latest != null)
                      DiagnosisHero(result: latest)
                    else
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)), // safe area for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 72,
              color: Colors.green.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Ready to Analyze',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start by scanning a crop leaf using the button below.\nGet instant health insights and recommendations.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}