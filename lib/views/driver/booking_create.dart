import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class BookingCreate extends StatefulWidget {
  const BookingCreate({super.key});

  @override
  State<BookingCreate> createState() => _BookingCreateState();
}

class _BookingCreateState extends State<BookingCreate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(












       bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
    );
  }
}