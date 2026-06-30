import 'package:flutter/material.dart';
import 'widgets/admin_bottom_nav.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Profile"),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Admin Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }
}
