import 'package:flutter/material.dart';

class ScanBottomSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;
  final bool isPredicting;

  const ScanBottomSheet({
    super.key,
    required this.onGallery,
    required this.onCamera,
    required this.isPredicting,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Scan Crop',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Take a photo or upload from gallery\nof the affected leaf',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 48),

              // Scan Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ScanOptionButton(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: onCamera,
                    isDark: isDark,
                  ),
                  _ScanOptionButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: onGallery,
                    isDark: isDark,
                  ),
                ],
              ),

              // Loading State
              if (isPredicting) ...[
                const SizedBox(height: 50),
                const CircularProgressIndicator(
                  color: Color(0xFF4CAF50),
                  strokeWidth: 5,
                ),
                const SizedBox(height: 20),
                Text(
                  'Analyzing image...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Scan Option Button (Cleaner & Modern)
class _ScanOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ScanOptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 36,
              color: isDark ? Colors.white : const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}