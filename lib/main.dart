import 'package:bandariflow/views/admin/admin_dashboard.dart';
import 'package:bandariflow/views/auth/login_screen.dart';
import 'package:bandariflow/views/auth/register_screen.dart';
import 'package:bandariflow/views/driver/driver_dashboard.dart';
import 'package:bandariflow/views/driver/profile_page.dart';
import 'package:bandariflow/views/driver/tickets_page.dart';
import 'package:bandariflow/views/gate/scan.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bandariflow/services/api_service.dart';
import 'package:flutter/material.dart';
import 'views/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  try {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(alert: true, badge: true, sound: true);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    final fcmToken = await messaging.getToken();

    if (fcmToken != null) {
      await ApiService.uploadFCMToken(fcmToken);
      debugPrint("FCM TOKEN: $fcmToken");
    }
  } catch (e) {
    debugPrint("FCM init failed: $e");
  }

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
        '/dashboard': (context) => const DriverDashboard(),
        '/gatepass': (context) => const MyTicketsPage(),
        '/profile': (context) => const ProfilePage(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/scanner': (context) => const QrScannerPage(),
      },
    );
  }
}
