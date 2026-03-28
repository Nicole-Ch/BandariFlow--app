import 'package:bandariflow/views/auth/login_screen.dart';
import 'package:bandariflow/views/auth/register_screen.dart';
import 'package:bandariflow/views/driver/booking_detail.dart';
import 'package:bandariflow/views/driver/driver_dashboard.dart';
import 'package:flutter/material.dart';
import 'views/auth/splash_screen.dart';

void main() {
  runApp(const BandariFlowApp());
}

class BandariFlowApp extends StatelessWidget {
  const BandariFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BandariFlow',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const DriverDashboard(),
        //'/gatepass': (context) => const GatePassScreen()
        '/gatepass': (context) => const MyBookingsPage(),
        
      },
    );
  }
}