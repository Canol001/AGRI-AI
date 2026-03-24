import 'package:flutter/material.dart';
import 'dart:convert';
import '../services/api_service.dart'; // Adjust the path if necessary

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
    // {'code': 'luo', 'name': 'Luo', 'native': 'Dholuo'},
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
        setState(() => _userName = data['user'] ?? 'User');
      }

      if (profileRes.statusCode == 200) {
        final data = jsonDecode(profileRes.body);
        setState(() {
          _selectedLanguageCode = data['preferred_language'] ?? 'en';
        });
      }
    } catch (e) {
      print('Error loading settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load settings')),
        );
      }
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
        setState(() => _languageMessage = 'Language preference saved successfully!');
      } else {
        setState(() => _languageMessage = 'Failed to save language');
      }
    } catch (e) {
      setState(() => _languageMessage = 'Network error');
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
        setState(() => _passwordError = data['detail'] ?? "Failed to change password");
      }
    } catch (e) {
      setState(() => _passwordError = "Network error. Please try again.");
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3CBE45))),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[950] : const Color(0xFFF6F8F6),
appBar: AppBar(
  title: const Text(
    'Settings',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white, // Make the title text white
    ),
  ),
  centerTitle: true,
  elevation: 0,
  backgroundColor: Colors.green, // Green AppBar
  iconTheme: const IconThemeData(
    color: Colors.white, // Make icons white
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout_rounded),
      onPressed: () => _showLogoutDialog(context),
      color: Colors.white, // ensure logout icon is white
    ),
  ],
),

      // Original Sidebar (Drawer)
      drawer: _buildDrawer(context),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3CBE45),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Customize your Agri AI experience',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontSize: 15),
            ),
            const SizedBox(height: 32),

            // Language Selection
            const Text('Preferred Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),

            ..._languages.map((lang) {
              final isSelected = _selectedLanguageCode == lang['code'];
              return GestureDetector(
                onTap: () => setState(() => _selectedLanguageCode = lang['code']!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3CBE45) : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF3CBE45) : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Color(0xFF3CBE45), size: 20)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lang['native']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            Text(lang['name']!, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Color(0xFF3CBE45), size: 28),
                    ],
                  ),
                ),
              );
            }).toList(),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSavingLanguage ? null : _saveLanguage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3CBE45),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSavingLanguage
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Language Preference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            if (_languageMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _languageMessage!,
                  style: TextStyle(
                    color: _languageMessage!.contains('success') ? const Color(0xFF3CBE45) : Colors.red,
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Change Password Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_outline, color: Color(0xFF3CBE45), size: 28),
                      SizedBox(width: 12),
                      Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildTextField('Current Password', _currentPasswordController, obscure: true),
                  const SizedBox(height: 16),
                  _buildTextField('New Password', _newPasswordController, obscure: true),
                  const SizedBox(height: 16),
                  _buildTextField('Confirm New Password', _confirmPasswordController, obscure: true),

                  if (_passwordError != null)
                    Padding(padding: const EdgeInsets.only(top: 12), child: Text(_passwordError!, style: const TextStyle(color: Colors.red))),
                  if (_passwordMessage != null)
                    Padding(padding: const EdgeInsets.only(top: 12), child: Text(_passwordMessage!, style: const TextStyle(color: Color(0xFF3CBE45)))),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isChangingPassword ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3CBE45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isChangingPassword
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Update Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Other Settings Tiles
            _buildSettingsTile(Icons.notifications_outlined, 'Notifications', 'Push notifications & alerts'),
            _buildSettingsTile(Icons.dark_mode_outlined, 'Appearance', 'Light / Dark mode'),
            _buildSettingsTile(Icons.storage_outlined, 'Data & Storage', 'Offline mode & cache'),

            const SizedBox(height: 60),
            Center(
              child: Text(
                'Agri AI • Version 1.0.0 • © 2026',
                style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3CBE45).withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF3CBE45), size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon')),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3CBE45), Color(0xFF2E9B38)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.agriculture_rounded, size: 52, color: Colors.white),
                SizedBox(height: 12),
                Text('Agri AI', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
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
            title: const Text('Scan History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/analytics');
            },
          ),
          const Divider(height: 30),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            selected: true,
            selectedColor: const Color(0xFF3CBE45),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.logout();
              if (mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}