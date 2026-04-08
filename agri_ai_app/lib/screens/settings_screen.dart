// lib/screens/settings_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/settings/language_selector.dart';
import '../widgets/settings/change_password_card.dart';
import '../widgets/settings/settings_tile.dart';
import '../widgets/settings/settings_header.dart';
import '../widgets/dashboard/scan_bottom_sheet.dart';
import '../widgets/settings/loading_view.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = "User";
  String _selectedLanguageCode = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'sw', 'name': 'Swahili', 'native': 'Kiswahili'},
  ];

  bool _isLoading = true;
  bool _isSavingLanguage = false;
  bool _isChangingPassword = false;

  String? _languageMessage;
  String? _passwordMessage;
  String? _passwordError;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final dashboardRes = await ApiService.authenticatedGet('dashboard/');
      final profileRes = await ApiService.authenticatedGet('profile/');

      if (dashboardRes.statusCode == 200) {
        final data = jsonDecode(dashboardRes.body);
        _userName = data['user'] ?? 'User';
      }

      if (profileRes.statusCode == 200) {
        final data = jsonDecode(profileRes.body);
        _selectedLanguageCode = data['preferred_language'] ?? 'en';
      }
    } catch (e) {
      print('Error loading settings: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLanguage() async {
    setState(() => _isSavingLanguage = true);
    _languageMessage = null;

    try {
      final response = await ApiService.authenticatedPatch(
        'profile/',
        body: {'preferred_language': _selectedLanguageCode},
      );

      if (response.statusCode == 200) {
        _languageMessage = 'Language preference saved successfully!';
      } else {
        _languageMessage = 'Failed to save language';
      }
    } catch (e) {
      _languageMessage = 'Network error';
    } finally {
      setState(() => _isSavingLanguage = false);
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (newPass != confirm) {
      setState(() => _passwordError = "New passwords do not match");
      return;
    }
    if (newPass.length < 8) {
      setState(() => _passwordError = "Password must be at least 8 characters");
      return;
    }

    setState(() {
      _isChangingPassword = true;
      _passwordError = null;
      _passwordMessage = null;
    });

    try {
      final response = await ApiService.authenticatedPost(
        'change-password/',
        body: {'current_password': current, 'new_password': newPass},
      );

      if (response.statusCode == 200) {
        setState(() {
          _passwordMessage = "Password changed successfully!";
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        final data = jsonDecode(response.body);
        _passwordError = data['detail'] ?? "Failed to change password";
      }
    } catch (e) {
      _passwordError = "Network error. Please try again.";
    } finally {
      setState(() => _isChangingPassword = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return LoadingView();

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? null : const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3, // Settings is index 3
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
          if (index == 1) Navigator.pushReplacementNamed(context, '/history');
          if (index == 2) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ScanBottomSheet(
                onGallery: () {},
                onCamera: () {},
                isPredicting: false,
              ),
            );
          }
          if (index == 3) return;
          if (index == 4) Navigator.pushReplacementNamed(context, '/profile');
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsHeader(),

            const SizedBox(height: 32),

            LanguageSelector(
              selectedLanguageCode: _selectedLanguageCode,
              languages: _languages,
              onLanguageChanged: (code) => setState(() => _selectedLanguageCode = code),
              isSaving: _isSavingLanguage,
              onSave: _saveLanguage,
              message: _languageMessage,
            ),

            const SizedBox(height: 40),

            ChangePasswordCard(
              currentPasswordController: _currentPasswordController,
              newPasswordController: _newPasswordController,
              confirmPasswordController: _confirmPasswordController,
              isChanging: _isChangingPassword,
              error: _passwordError,
              successMessage: _passwordMessage,
              onChangePassword: _changePassword,
            ),

            const SizedBox(height: 40),

            SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Push notifications & alerts',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
            ),
            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: 'Appearance',
              subtitle: 'Light / Dark mode',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
            ),
            SettingsTile(
              icon: Icons.storage_outlined,
              title: 'Data & Storage',
              subtitle: 'Offline mode & cache',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
            ),

            const SizedBox(height: 60),
            Center(
              child: Text(
                'Agri AI • Version 1.0.0 • © 2026',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.grey[600] 
                      : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}