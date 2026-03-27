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
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),

                      Transform.translate(
                        offset: Offset(0, -4),
                        child: Container(
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
                      ),
                  
                  
                      

                    ],
                   
                  ),

                 
                  const SizedBox(height: 13),
                  const Center(
                    child: Text(
                      '01 : 14 : 22',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                                  
                   SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('HRS',
                         style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12
                         ),
                      ),
                      Text('MIN',
                         style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12
                         ),
                      ),
                      Text('SEC',
                         style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12
                         ),
                      ),
                    ],
                    
                  ),
                  SizedBox(height: 8),
                   Divider(color: Colors.white24, height: 1),
                   SizedBox(height: 14),

                  //MAP
                  Row(
                   children: [
                    Expanded(child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF123B73),
                          ),
                          child: Icon(Icons.access_time,color: Colors.white,size: 20),
                        ),

                        SizedBox(width: 10),

                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gate Window',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(height: 2),
                            Text('14:00 - 15:00',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          ],
                        )
                        ),
                      ],
                    )),
                    SizedBox(width: 10),
                     const VerticalDivider( //CHECK ON THIS
                            width: 20,
                            thickness: 1,
                            indent: 20,
                            endIndent: 0,
                            color: Colors.grey,
                          ),
                    Expanded(child: Row(children: [
                      Container(
                        width: 36,
                        height:36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF123B73),
                        ),           
                        child: Icon(Icons.local_shipping, color: Colors.white, size: 20),        
                           ),

                           SizedBox(width: 10),
                           Expanded(
                            child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text('Container',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                ),
                                SizedBox(height: 2),
                                Text('TGBU123456',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                ),

                           ],))
                    ],))
                   ],
                    
                  )
                ],
              ),
            ),
          

          SizedBox(height: 16),
          
          //Yard Capacity
          Container(
            padding: const EdgeInsets.all(16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text('Yard Capacity Heatmap',
                   style: TextStyle(
                    color: Color(0xFF0A2342),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                  
                  ),
                ),

                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    shape: BoxShape.circle
                  ),
                  child: Icon(Icons.info_outline,
                   size: 16,
                   color: Colors.grey,
                  ),
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