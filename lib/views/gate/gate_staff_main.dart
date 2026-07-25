import 'package:flutter/material.dart';
import 'scan.dart';
import 'scan_history_page.dart';

class GateStaffMainScreen extends StatefulWidget {
  const GateStaffMainScreen({super.key});

  @override
  State<GateStaffMainScreen> createState() => _GateStaffMainScreenState();
}

class _GateStaffMainScreenState extends State<GateStaffMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [QrScannerPage(), ScanHistoryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
