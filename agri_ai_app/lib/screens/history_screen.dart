// lib/screens/history_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/history/history_card.dart';
import '../widgets/history/history_details_sheet.dart';
import '../widgets/history/empty_history_view.dart';
import '../widgets/history/loading_view.dart';
import '../widgets/history/error_view.dart';

import '../widgets/dashboard/scan_bottom_sheet.dart';   // ← This was missing

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
        ApiService.authenticatedGet('recent-scans/'),
      ]);

      if (results[0].statusCode == 200) {
        final data = jsonDecode(results[0].body);
        _totalScans = (data['total_scans'] as num?)?.toInt() ?? 0;
      }

      if (results[1].statusCode == 200) {
        final scansData = jsonDecode(results[1].body);
        if (scansData is List) {
          _scans = List<Map<String, dynamic>>.from(scansData);
        }
      }
    } catch (e) {
      _errorMessage = 'Could not load history. Check your connection.';
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
        title: const Text('Delete Scan?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.red.shade700)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    try {
      final res = await ApiService.authenticatedDelete('scans/$scanId/');
      if (res.statusCode >= 200 && res.statusCode < 300 && mounted) {
        setState(() {
          _scans.removeWhere((s) => s['id']?.toString() == scanId);
          _totalScans = (_totalScans - 1).clamp(0, _totalScans);
          _selectedScan = null;
        });
      }
    } catch (e) {
      _deleteError = 'Failed to delete scan.';
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) return const LoadingView();
    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _loadHistory);
    }

    return Scaffold(
      backgroundColor: isDark ? null : const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Scan History'),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavBar(
  currentIndex: 1,
  onTap: (index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 2:
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ScanBottomSheet(
            onGallery: () => {}, // connect later
            onCamera: () => {},
            isPredicting: false,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/settings');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  },
),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: const Color(0xFF4CAF50),
        child: _scans.isEmpty
            ? const EmptyHistoryView()
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                          return HistoryCard(
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
          ? HistoryDetailsSheet(
              scan: _selectedScan!,
              isDeleting: _isDeleting,
              deleteError: _deleteError,
              onClose: () => setState(() => _selectedScan = null),
              onDelete: () => _deleteScan(_selectedScan!),
            )
          : null,
    );
  }
}