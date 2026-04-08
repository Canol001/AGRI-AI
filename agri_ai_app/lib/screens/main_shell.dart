// lib/screens/main_shell.dart
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const HistoryScreen(),
    const SizedBox(), // Placeholder for Scan (handled by bottom sheet)
    const SettingsScreen(),
    const Center(child: Text("Profile Screen - Coming Soon")), // Replace later
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : (_currentIndex > 2 ? _currentIndex - 1 : _currentIndex),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            // Open Scan Bottom Sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ScanBottomSheet(
                onGallery: () {}, // Connect to controller
                onCamera: () {},
                isPredicting: false,
              ),
            );
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
    );
  }
}