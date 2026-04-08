import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
const AboutUsPage({super.key});

@override
Widget build(BuildContext context) {
final isDark = Theme.of(context).brightness == Brightness.dark;

return Scaffold(
  appBar: AppBar(
    title: const Text("About Agri AI"),
    elevation: 0,
  ),
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // APP HEADER
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.green.shade100,
                child: const Icon(
                  Icons.eco,
                  size: 45,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Agri AI",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Smart Crop Disease Detection",
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // MISSION
        const Text(
          "Our Mission",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Agri AI helps farmers and agricultural professionals quickly "
          "identify crop diseases using artificial intelligence. "
          "By simply scanning a leaf with your phone, the app analyzes "
          "the image and provides an instant diagnosis along with "
          "recommendations to protect your crops.",
          style: TextStyle(height: 1.6),
        ),

        const SizedBox(height: 30),

        // FEATURES
        const Text(
          "Key Features",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _featureItem(Icons.camera_alt, "Scan crops using your phone camera"),
        _featureItem(Icons.analytics, "AI-powered disease detection"),
        _featureItem(Icons.history, "View recent crop scan history"),
        _featureItem(Icons.insights, "Smart recommendations for treatment"),

        const SizedBox(height: 30),

        // TECHNOLOGY
        const Text(
          "Technology",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Agri AI combines deep learning image recognition models "
          "with modern mobile technology to make crop diagnosis "
          "fast, reliable, and accessible to everyone.",
          style: TextStyle(height: 1.6),
        ),

        const SizedBox(height: 30),

        // FOOTER
        Center(
          child: Column(
            children: const [
              Text(
                "Built for smarter farming 🌱",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 6),
              Text(
                "Version 1.0",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        )
      ],
    ),
  ),
);

}

static Widget _featureItem(IconData icon, String text) {
return Padding(
padding: const EdgeInsets.only(bottom: 10),
child: Row(
children: [
Icon(icon, color: Colors.green),
const SizedBox(width: 10),
Expanded(child: Text(text)),
],
),
);
}
}
