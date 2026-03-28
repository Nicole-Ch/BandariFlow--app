import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: const Center(
        child: Text('Profile Page'),
      ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 3),
    );
  }
}