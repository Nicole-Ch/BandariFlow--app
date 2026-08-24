import 'package:flutter/material.dart';
import 'package:bandariflow/views/driver/booking_create.dart';
import 'package:bandariflow/views/driver/driver_dashboard.dart';
import 'package:bandariflow/views/driver/profile_page.dart';
import 'package:bandariflow/views/driver/tickets_page.dart';

class DriverBottomNav extends StatelessWidget {
  final int currentIndex;

  const DriverBottomNav({super.key, required this.currentIndex});

  void _goToPage(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const DriverDashboard();
        break;
      case 1:
        page = const BookingCreate();
        break;
      case 2:
        page = const MyTicketsPage();
        break;
      case 3:
        page = const ProfilePage();
        break;
      default:
        page = const DriverDashboard();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      selectedItemColor: const Color(0xFF0A2342),
      unselectedItemColor: Colors.black54,
      backgroundColor: Colors.white,
      elevation: 4,
      onTap: (index) => _goToPage(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Book',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.confirmation_num_outlined),
          label: 'My Tickets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
