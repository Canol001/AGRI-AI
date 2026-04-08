import 'package:flutter/material.dart';

class ChangePasswordCard extends StatelessWidget {
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool isChanging;
  final String? error;
  final String? successMessage;
  final VoidCallback onChangePassword;

  const ChangePasswordCard({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.isChanging,
    this.error,
    this.successMessage,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
              Icon(Icons.lock_outline, color: Color(0xFF4CAF50), size: 28),
              SizedBox(width: 12),
              Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),

          _buildTextField('Current Password', currentPasswordController, obscure: true),
          const SizedBox(height: 16),
          _buildTextField('New Password', newPasswordController, obscure: true),
          const SizedBox(height: 16),
          _buildTextField('Confirm New Password', confirmPasswordController, obscure: true),

          if (error != null)
            Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: const TextStyle(color: Colors.red))),
          if (successMessage != null)
            Padding(padding: const EdgeInsets.only(top: 12), child: Text(successMessage!, style: const TextStyle(color: Color(0xFF4CAF50)))),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isChanging ? null : onChangePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: isChanging
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Update Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
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
}