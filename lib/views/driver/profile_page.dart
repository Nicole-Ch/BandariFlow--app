import 'package:bandariflow/views/driver/update_profile.dart';
import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
               children: [
                //TOP BAR
                 Container(
                
                padding: EdgeInsets.symmetric(horizontal: 16, vertical:14),
                decoration: BoxDecoration(
                  color: Color(0xFF0A2342),
                  
                ),
          
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  
                   Icon(Icons.anchor,color: Colors.white, size: 30),
                   
                    Text('Profile',
                      style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    ),
          
                   
          
                    Icon(Icons.notifications, color: Colors.white, size: 30)
          
                    
                  ],
                ),
              ),
              
              SizedBox(
                width: 120, 
                height: 120,
                child: ClipRRect
                ( borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                  'assets/images/profile.jpg', 
                  height: 120, 
                  width: 120),
                  ),
              ),
          
              SizedBox(height: 10),
              Text('Jacob' ,
              style: TextStyle(
                 fontSize: 25,
                 fontWeight: FontWeight.w800
              )),
              Text('jacobdriver@gmail.com' ,
              style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w500
              )),
          
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: (){
                  MaterialPageRoute(builder: (context) => UpdateProfilePage());
              }, style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 12, 44, 83),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              ),
              
               child: Text('Edit Profile'),
                 
              ),
          
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0,4),
                    )
                  ]
                ),
                child: Column(
                  children: [
                      _profileItem(
                        icon: Icons.phone_android_outlined, 
                        title: 'Phone',
                         value: '+254 700963017'),

                      SizedBox(height: 10),
                      Divider(height: 1),
                      SizedBox(height: 10),   

                       _profileItem(
                        icon: Icons.mail_outline, 
                        title: 'Email',
                         value: 'jacobdriver@gmail.com'),

                      SizedBox(height: 10),
                      Divider(height: 1),
                      SizedBox(height: 10),   

                       _profileItem(
                        icon: Icons.local_shipping_outlined, 
                        title: 'Truck',
                         value: 'KBX 123Z'),

                      SizedBox(height: 10),
                      Divider(height: 1),
                      SizedBox(height: 10), 
                      
                     Container(
  width: double.infinity,
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Account',
        style: TextStyle(
          color: Color(0xFF0A2342),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),

      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFD6D6)),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout_outlined, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'Log out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              Icon(Icons.chevron_right, color: Colors.red),
            ],
          ),
        ),
      ),
    ],
  ),
),
                  ],
                ),
              )
               
          
              
          
              
               ],
          ),
        )),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 3),
    );
  }
}

Widget _profileItem({
  required IconData icon,
  required String title,
  required String value,
}){
  return Row(children: [
    Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Color(0xFFEAF1FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon, 
        color: Color(0xFF0A2342),
        size: 22,
      ),

      
    ),

    SizedBox(width: 12),

    Expanded(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
          ),
          SizedBox(height:2),
          Text(value,
          style: TextStyle(
            color: Color(0xFF0A2342),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          )
      ],
    ))
  ],);
}