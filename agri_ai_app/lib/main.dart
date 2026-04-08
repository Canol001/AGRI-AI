import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // if needed for init

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart'; // or home_screen.dart — whatever name you use
import 'screens/history_screen.dart';   // ← from previous response
import 'screens/analytics_screen.dart'; // create placeholder
import 'screens/settings_screen.dart';   // create placeholder
import 'screens/profile_screen.dart'; // create placeholder
import 'services/check_update.dart'; // new service for version check

void main() {
  runApp(const AgriAIApp());
}

class AgriAIApp extends StatelessWidget {
  const AgriAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        // ✅ Run version check after first frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // CheckUpdateService.checkForUpdate(context);
          checkForUpdate(context);
        });

        return MaterialApp(
          title: 'Agri AI - Crop Disease Diagnosis',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green.shade700,
              primary: Colors.green.shade700,
              secondary: Colors.greenAccent.shade700,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.grey.shade50,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/history': (context) => const HistoryScreen(),
            '/analytics': (context) => const AnalyticsScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                  child: Text(
                    '404 - Route not found!\nReturning to login...',
                    style: TextStyle(fontSize: 20, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}