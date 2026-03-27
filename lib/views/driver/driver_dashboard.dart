import 'package:flutter/material.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _selectedIndex = 0; // For Navigation Bar state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

      body: SafeArea(
        child: ListView(
        //padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          //TOB BAR

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: Color(0xFF0A2342),
            ),
              
            child: Row(
             
              children: [
                Icon(Icons.anchor, color: Colors.white, size: 26,),
                 SizedBox(width: 8),
                 Text('BandariFlow',
                    style:TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                                ),
                  Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(Icons.person, color: Color(0xFF0A2342),),
                )
               
                
              ],
            ),
          ),

          SizedBox(height: 16),

          //ACTIVE BOOKING CARD
          Container(
            padding: const EdgeInsets.all(16),
              
              decoration: BoxDecoration(
                 color: Color(0xFF0A2342),
                 borderRadius: BorderRadius.circular(20) ,
                 boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                 ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF1D6F4E),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: Color(0xFF59E38C),),
                            SizedBox(width: 6,),
                            Text('LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12
                                ),
                            )
                          ],
                        ),
                      ),

                    ],
                   
                  ),

                  SizedBox(height: 10),

                  Text('CURRENT SLOT STATUS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  
                  SizedBox(height: 4),
                  Text('Countdown to your active booking window',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      
                    ),
                  ),

                   SizedBox(height: 18),
                  Center(
                    child: Text('01 : 14 : 22',
                       style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2
                       ),
                    ),
                    
                  ),
                  SizedBox(height: 8),

                  //MAP
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('Map Preview'),
                    ),
                  )
                ],
              ),
            ),
          

          SizedBox(height: 20),
          
          //Yard Capacity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text('Yard Capacity',
                 style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                
                ),
                SizedBox(height: 10),

                Row(
                    children: [
                      _statusDot("Maersk", Colors.green),
                      _statusDot("MSC", Colors.red),
                      _statusDot("CMA", Colors.orange),
                    ],
                  )
              ],
            ),
          ),

          Spacer(),

          

          

          




        ],
      )),
          
          //BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedItemColor: const Color(0xFF0A2342),
        unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_outlined), label: 'Scan Docs'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num_outlined), label: 'My Tickets'),
         BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}


Widget _statusDot(String label, Color color){
  return Padding(padding: EdgeInsets.only(right: 12),
  child: Row(
    children: [
      CircleAvatar(radius: 5, backgroundColor: color,),
      SizedBox(width: 6),
      Text(label),
    ],
  ),
  
  );


}