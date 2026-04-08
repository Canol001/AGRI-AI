import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> scan;
  final VoidCallback onTap;

  const HistoryCard({super.key, required this.scan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Data Parsing
    final disease = scan['disease']?.toString() ?? scan['disease_name']?.toString() ?? 'Unknown';
    final confidence = (scan['confidence'] as num?)?.toDouble() ?? 0.0;
    final dateStr = scan['date'] ?? scan['created_at'];
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;

    // Logic for styling
    final isHighConf = confidence >= 85;
    final Color accentColor = isHighConf ? Colors.green.shade600 : Colors.orange.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Hero(
                    tag: scan['id'] ?? 'image_${scan['image']}', // Matches the Detail Sheet Tag
                    child: AspectRatio(
                      aspectRatio: 16 / 10, // Wider, more cinematic aspect ratio
                      child: Image.network(
                        'http://199.231.191.165:8000${scan['image']}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: isDark ? Colors.grey[900] : Colors.grey[200],
                          child: Icon(Icons.image_not_supported_rounded, 
                            size: 40, color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ),
                  // Confidence Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${confidence.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.w800, 
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              // Text Content Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w800, 
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_rounded, 
                          size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          date != null ? DateFormat('MMMM d, yyyy').format(date) : 'Unknown date',
                          style: TextStyle(
                            fontSize: 13, 
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded, 
                          size: 14, color: Colors.grey.shade400),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}