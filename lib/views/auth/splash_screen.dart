import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/admin/admin_dashboard.dart';
import 'package:bandariflow/views/gate/scan.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import '../driver/driver_dashboard.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    //  Give the splash animation 2 seconds to display smoothly
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (!mounted) return;

    //  If no token exists, navigate straight to the login screen
    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    try {
      print("=== SPLASH CHECK: Token found. Verifying user role... ===");

      //  Request the profile details from Django
      final profile = await ApiService.getDriverProfile();

      //  Safely extract the role parameter from your nested user object
      final role = profile['user']?['role']?.toString().toLowerCase();
      print("=== SPLASH CHECK: Found user role: $role ===");

      if (!mounted) return;

      //  Navigate based on their actual account permissions
      if (role == 'admin') {
        print("=== SPLASH CHECK: Routing to Admin Dashboard ===");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboard()),
        );
      } else if (role == 'gatestaff') {
        print("=== SPLASH CHECK: Routing to Gate Staff Dashboard ===");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QrScannerPage()),
        );
      } else {
        print("=== SPLASH CHECK: Routing to Driver Dashboard ===");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DriverDashboard()),
        );
      }
    } catch (e) {
      print("=== SPLASH CHECK ERROR: Profile check failed: $e ===");

      //  If the token is invalid or a network failure occurs, fall back to login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2342),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0C56B0).withValues(alpha: 0.35),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2D7DDA).withValues(alpha: 0.25),
                ),
              ),
            ),

            Positioned(
              bottom: -50,
              left: -30,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF66B7F3).withValues(alpha: 0.2),
                ),
              ),
            ),

            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                child: Container(color: Colors.transparent),
              ),
            ),

            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 190,
                          height: 190,
                          fit: BoxFit.contain,
                          color: Colors.black,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'BandariFlow',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // App Subtitle Text
                      Text(
                        'Port Logistics Ecosystem',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Clean, modern micro-loading spinner
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
