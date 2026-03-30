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
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Create Booking'),
        centerTitle: true,
        backgroundColor: Color(0xFF0D3B8E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(child: Container(
          
        )),
      )),












       bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
    );
  }
}