import 'package:flutter/material.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final truckController = TextEditingController();
  final licenseController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
       appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SingleChildScrollView(
         child: Column(
           children: [
            SizedBox(height: 5,),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFFBFD6F6),
                      width: 3,
                    ),
                    image: DecorationImage(image: AssetImage('assets/images/profile.jpg'),
                     fit: BoxFit.cover,
                    ),
                  ),
                ),

                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2F6FD6),
                  ),
                  child: Icon(Icons.camera_alt,
                   color: Colors.white,
                   size: 18,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

            Text('Edit',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            ),
               
             
               
           ],
         ),),
      
        
    
        );
  }
}