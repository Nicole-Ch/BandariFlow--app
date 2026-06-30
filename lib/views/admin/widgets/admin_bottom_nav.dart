import 'package:flutter/material.dart';
import '../admin_dashboard.dart';
import '../booking_page.dart';
import '../admin_alerts.dart';
import '../admin_profile.dart';

class AdminBottomNav extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNav({super.key, required this.currentIndex});

  void _goToPage(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;

    switch (index) {
      case 0:
        page = const AdminDashboard();
        break;

      case 1:
        page = const BookingsPage();
        break;

      case 2:
        page = const AlertsPage();
        break;

      case 3:
        page = const AdminProfilePage();
        break;

      default:
        page = const AdminDashboard();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF0A2342),
      unselectedItemColor: Colors.grey,
      onTap: (index) => _goToPage(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: "Dashboard",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          label: "Bookings",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_outlined),
          label: "Alerts",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profile",
        ),
      ],
    );
  }
}
