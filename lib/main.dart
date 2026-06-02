import 'package:bandariflow/views/admin/admin_dashboard.dart';
import 'package:bandariflow/views/auth/login_screen.dart';
import 'package:bandariflow/views/auth/register_screen.dart';
import 'package:bandariflow/views/driver/driver_dashboard.dart';
import 'package:bandariflow/views/driver/profile_page.dart';
import 'package:bandariflow/views/driver/tickets_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:bandariflow/services/api_service.dart';
import 'package:flutter/material.dart';
import 'views/auth/splash_screen.dart';

void main() async {
  //  Ensure internal engine channels are bound before calling asynchronous plugins
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize the background Firebase core cloud infrastructure context loop
  await Firebase.initializeApp();

  // Request pushdown permission flags from the mobile device OS layout layer
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Displays the drop-down banner card heads-up display
    badge: true, // Displays the app icon notification counter numbers
    sound: true, // Triggers the system alerts audio chime sound path
  );

  // Pull the device tracking token straight from the Firebase network
  String? fcmToken = await messaging.getToken();

  // upload token to Django backend database
  if (fcmToken != null) {
    await ApiService.uploadFCMToken(fcmToken);
  }

  debugPrint("========================================================");
  debugPrint("DRIVER DEVICE RECTIFICATION FCM TOKEN:");
  debugPrint("$fcmToken");
  debugPrint("========================================================");

  // Launches  BandariFlowApp root layout class
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
      },
    );
  }
}
