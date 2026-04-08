// lib/widgets/dashboard/footer_note.dart
import 'package:flutter/material.dart';

class FooterNote extends StatelessWidget {
  const FooterNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const Divider(thickness: 1, color: Colors.grey),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.eco_rounded,
                size: 18,
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 8),
              Text(
                "Powered by Agri AI • Helping Farmers Grow Better",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Version 1.2.0",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}