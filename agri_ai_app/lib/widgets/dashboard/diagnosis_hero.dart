import 'package:flutter/material.dart';

class DiagnosisHero extends StatelessWidget {
  final Map<String, dynamic> result;

  const DiagnosisHero({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final disease = result['disease']?.toString() ?? 'Unknown';
    final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.0;
    final rec = result['recommendation'] as Map<String, dynamic>?;

    final isHighConf = confidence >= 85;
    final color = isHighConf ? Colors.green : Colors.orange;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result['image'] != null)
            Image.network(
              'http://199.231.191.165:8000${result['image']}',
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        disease,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
                      ),
                    ),
                    Chip(
                      label: Text(isHighConf ? 'HIGH CONFIDENCE' : 'Detected'),
                      backgroundColor: color.withOpacity(0.15),
                      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${confidence.toStringAsFixed(1)}% confidence',
                  style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),

                if (rec != null) ...[
                  const Text('What to do now', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(rec['treatment']?.toString() ?? '—', style: const TextStyle(height: 1.5)),
                  const SizedBox(height: 20),
                  const Text('Prevention tips', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(rec['prevention']?.toString() ?? '—', style: const TextStyle(height: 1.5)),
                ] else ...[
                  const Text('Loading recommendations...', style: TextStyle(color: Colors.grey)),
                ],

                const SizedBox(height: 24),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Scan Again'),
                      onPressed: () {
                        // You can re-trigger bottom sheet here if desired
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.green.shade700),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('History'),
                      onPressed: () => Navigator.pushNamed(context, '/history'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}