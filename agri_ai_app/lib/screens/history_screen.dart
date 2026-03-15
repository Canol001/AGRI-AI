// lib/screens/history_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _scans = [];
  int _totalScans = 0;

  Map<String, dynamic>? _selectedScan;
  bool _isDeleting = false;
  String? _deleteError;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await ApiService.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final results = await Future.wait([
        ApiService.authenticatedGet('dashboard/'),
        ApiService.authenticatedGet('recent-scans/'), // consider pagination later
      ]);

      if (results[0].statusCode == 200) {
        final data = jsonDecode(results[0].body);
        if (mounted) {
          setState(() {
            _totalScans = (data['total_scans'] as num?)?.toInt() ?? 0;
          });
        }
      }

      if (results[1].statusCode == 200) {
        final scansData = jsonDecode(results[1].body);
        if (scansData is List && mounted) {
          setState(() {
            _scans = List<Map<String, dynamic>>.from(scansData);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load history. Check your connection.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteScan(Map<String, dynamic> scan) async {
    final scanId = scan['id']?.toString();
    if (scanId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this scan?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
      _deleteError = null;
    });

    try {
      final res = await ApiService.authenticatedDelete('scans/$scanId/');
      if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
        setState(() {
          _scans.removeWhere((s) => s['id']?.toString() == scanId);
          _totalScans = (_totalScans - 1).clamp(0, _totalScans);
          _selectedScan = null;
        });
      } else {
        throw Exception('Delete failed (${res.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _deleteError = 'Failed to delete scan.');
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const _LoadingView();
    if (_errorMessage != null) {
      return _ErrorView(message: _errorMessage!, onRetry: _loadHistory);
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.brightness == Brightness.dark ? null : const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Scan History'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.camera_alt_rounded),
        label: const Text('New Scan'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: Colors.green.shade700,
        child: _scans.isEmpty
            ? _EmptyHistoryView()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final scan = _scans[index];
                          return _HistoryCard(
                            scan: scan,
                            onTap: () => setState(() => _selectedScan = scan),
                          );
                        },
                        childCount: _scans.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomSheet: _selectedScan != null
          ? _DetailsBottomSheet(
              scan: _selectedScan!,
              isDeleting: _isDeleting,
              deleteError: _deleteError,
              onClose: () => setState(() => _selectedScan = null),
              onDelete: () => _deleteScan(_selectedScan!),
            )
          : null,
    );
  }

  Drawer _buildDrawer() {
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
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: const Text('History'),
            selected: true,
            selectedTileColor: Colors.green.shade50,
            selectedColor: Colors.green.shade800,
            onTap: () => Navigator.pop(context),
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
}

// ────────────────────────────────────────────────
// Components
// ────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> scan;
  final VoidCallback onTap;

  const _HistoryCard({required this.scan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disease = scan['disease']?.toString() ?? scan['disease_name']?.toString() ?? 'Unknown';
    final confidence = (scan['confidence'] as num?)?.toDouble() ?? 0.0;
    final dateStr = scan['date'] ?? scan['created_at'];
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

    final isHighConf = confidence >= 85;
    final confColor = isHighConf ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    'http://199.231.191.165:8000${scan['image']}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: confColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Text(
                      '${confidence.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    disease,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('MMM d, yyyy').format(date)
                        : 'Unknown date',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Tap for details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> scan;
  final bool isDeleting;
  final String? deleteError;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const _DetailsBottomSheet({
    required this.scan,
    required this.isDeleting,
    this.deleteError,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final disease = scan['disease']?.toString() ?? 'Unknown';
    final confidence = (scan['confidence'] as num?)?.toDouble() ?? 0.0;
    final dateStr = scan['date'] ?? scan['created_at'];
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final rec = scan['recommendation'] as Map<String, dynamic>?;

    final isHigh = confidence >= 85;
    final color = isHigh ? Colors.green : Colors.orange;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(999)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          disease,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.1),
                        ),
                      ),
                      Chip(
                        label: Text(isHigh ? 'High Confidence' : 'Detected'),
                        backgroundColor: color.withOpacity(0.15),
                        labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${confidence.toStringAsFixed(1)}% confidence • ${date != null ? DateFormat('MMM d, yyyy • h:mm a').format(date) : 'Unknown date'}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                  ),
                  const SizedBox(height: 24),

                  if (scan['image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'http://199.231.191.165:8000${scan['image']}',
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 240,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),

                  _Section(title: 'Treatment', content: rec?['treatment'] ?? 'No treatment information available.'),
                  const SizedBox(height: 24),
                  _Section(title: 'Prevention', content: rec?['prevention'] ?? 'No prevention advice available.'),

                  if (deleteError != null) ...[
                    const SizedBox(height: 24),
                    Text(deleteError!, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500)),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: isDeleting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Icon(Icons.delete_rounded),
                    label: Text(isDeleting ? 'Deleting...' : 'Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: isDeleting ? null : onDelete,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;

  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.green.shade800),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(content, style: const TextStyle(height: 1.5)),
        ),
      ],
    );
  }
}

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
            Text('Loading scan history…'),
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
              Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 100, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            const Text(
              'No scans yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your crop diagnoses will appear here once you start scanning.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Start Scanning'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}