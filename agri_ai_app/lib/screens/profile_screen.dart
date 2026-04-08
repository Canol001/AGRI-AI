import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4, // Profile index in your nav
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
          if (index == 1) Navigator.pushReplacementNamed(context, '/history');
          if (index == 2) {
            // Open Scan bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const Center(
                child: Text('ScanBottomSheet Placeholder'),
              ),
            );
          }
          if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
          if (index == 4) return; // Already on Profile
        },
      ),
      body: const Center(
        child: Text(
          'Profile Screen Placeholder',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}