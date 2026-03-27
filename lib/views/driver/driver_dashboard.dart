import 'package:flutter/material.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

      body: SafeArea(child: Column(
        children: [
          //TOB BAR

          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
             color: Color(0xFF0A2342), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.anchor, color: Colors.white),
                     SizedBox(width: 8),
                     Text('BandariFlow',
                        style:TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )
                ),
                  ],
                ),

                CircleAvatar(backgroundColor: Colors.white,
                   child: Icon(Icons.person,color: Colors.black,),
                )
               
                
              ],
            ),
          ),

          SizedBox(height: 16),

          //ACTIVE BOOKING CARD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                 color: Color(0xFF0A2342),
                 borderRadius: BorderRadius.circular(16) 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('ACTIVE BOOKING',
                    
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(height: 4),

                  Divider(
                    color: Colors.white54,
                    thickness: 1,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Text(
                           'GATE WINDOW:\n14:00 - 15:00',
                           style: TextStyle(
                              color: Colors.white70
                           ),
                           ),
                       ),

                       Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Text(
                            "Container:\nTGBU1234567",
                            style: TextStyle(
                              color: Colors.white70),
                          ),
                       ),

                    ],
                  ),
                  SizedBox(height: 16,),

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

          //BUTTON

          Padding(padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(onPressed: (){},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                )
              ),
              
              
               child: Text('VIEW GATE PASS',
                 style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
              )),
            ),
          )




        ],
      )),
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