import 'package:flutter/material.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {

  final fullNameController = TextEditingController(text: 'Jacob');
  final phoneController = TextEditingController(text: '+254 700963017');
  final emailController = TextEditingController(text: 'jacobdriver@gmail.com');
  final truckController = TextEditingController(text: 'KBX 123Z');
  final licenseController = TextEditingController(text: 'A12345678');
  final passwordController = TextEditingController(text: 'password123');

  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(child: 
      SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16),
         child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28)
          ),
         ),
        ),
      )),
    );
  }
}