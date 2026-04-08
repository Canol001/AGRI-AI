import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selectedLanguageCode;
  final List<Map<String, String>> languages;
  final Function(String) onLanguageChanged;
  final bool isSaving;
  final VoidCallback onSave;
  final String? message;

  const LanguageSelector({
    super.key,
    required this.selectedLanguageCode,
    required this.languages,
    required this.onLanguageChanged,
    required this.isSaving,
    required this.onSave,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Preferred Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),

        ...languages.map((lang) {
          final isSelected = selectedLanguageCode == lang['code'];
          return GestureDetector(
            onTap: () => onLanguageChanged(lang['code']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
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
                        color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: const Color(0xFF4CAF50), size: 20)
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
                    const Icon(Icons.check_circle, color: const Color(0xFF4CAF50), size: 28),
                ],
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isSaving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save Language Preference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),

        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              message!,
              style: TextStyle(
                color: message!.contains('success') ? const Color(0xFF4CAF50) : Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}