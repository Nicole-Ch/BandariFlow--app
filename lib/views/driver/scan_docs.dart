import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';


class ScanDocsPage extends StatelessWidget {
  const ScanDocsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: const Center(
        child: Text('Scan Docs Page'),
      ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
    );
  }
}