import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> scan;
  final bool isDeleting;
  final String? deleteError;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const HistoryDetailsSheet({
    super.key,
    required this.scan,
    required this.isDeleting,
    this.deleteError,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final disease = scan['disease']?.toString() ?? 'Unknown';
    final confidence = (scan['confidence'] as num?)?.toDouble() ?? 0.0;
    final dateStr = scan['date'] ?? scan['created_at'];
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    final rec = scan['recommendation'] as Map<String, dynamic>?;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section with Floating Badge
                  Stack(
                    children: [
                      Hero(
                        tag: scan['id'] ?? 'image',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            'http://199.231.191.165:8000${scan['image']}',
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 280,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[900] : Colors.grey[200],
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(Icons.image_not_supported_rounded, size: 40),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.analytics_rounded, size: 16, color: Colors.green.shade700),
                              const SizedBox(width: 6),
                              Text(
                                '${confidence.toStringAsFixed(0)}% Match',
                                style: TextStyle(
                                  color: isDark ? Colors.green.shade400 : Colors.green.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Header Information
                  Text(
                    disease,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        date != null ? DateFormat('MMMM d, yyyy • h:mm a').format(date) : 'Unknown date',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Treatment Section
                  _ModernSection(
                    title: 'Recommended Treatment',
                    icon: Icons.medication_rounded,
                    content: rec?['treatment'] ?? 'No treatment information available.',
                    accentColor: Colors.blue.shade600,
                  ),

                  const SizedBox(height: 20),

                  // Prevention Section
                  _ModernSection(
                    title: 'Prevention Guide',
                    icon: Icons.shield_rounded,
                    content: rec?['prevention'] ?? 'No prevention advice available.',
                    accentColor: Colors.green.shade600,
                  ),

                  if (deleteError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          deleteError!,
                          style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 34),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border(
                top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onClose,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      // Corrected: RoundedRectangleBorder instead of RoundedRectangleEdges
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isDeleting ? null : onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Delete Report', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color accentColor;

  const _ModernSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: accentColor),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}