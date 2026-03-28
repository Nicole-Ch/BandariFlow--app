import 'package:bandariflow/views/driver/booking_detail.dart';
import 'package:bandariflow/views/driver/gate_pass_screen.dart';
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
        padding: EdgeInsets.zero,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
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
            
                   
                    const SizedBox(height: 11),
                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Column(
                          children: [
                            Text(
                              '01',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'HRS',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                           
                             SizedBox(width: 12), 
                          Padding(
                                padding: EdgeInsets.only(bottom: 20), 
                                child: Text(':', 
                                style: TextStyle(
                                  color: Colors.white38, 
                                  fontSize: 30, 
                                  fontWeight: FontWeight.bold)),
                              ),
                             SizedBox(width: 12), 
            
                        Column(
                          children: [
                            Text(
                              '14',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'MIN',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(width: 12), 
                        Padding(
                                padding: EdgeInsets.only(bottom: 20), 
                                child: Text(':', 
                                style: TextStyle(
                                  color: Colors.white38, 
                                  fontSize: 30, 
                                  fontWeight: FontWeight.bold)),
                              ),
                         SizedBox(width: 12), 
            
                        Column(
                          children: [
                            Text(
                              '22',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'SEC',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                                    
                     SizedBox(height: 3),
                   
                      
                    
                    SizedBox(height: 8),
                     Divider(color: Colors.white24, height: 1),
                     SizedBox(height: 10),
            
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
                       Container(
                          height: 30, 
                          width: 1,
                          color: Colors.white24,
                        ),
            
                        SizedBox(width: 10),
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
          ),
          

          SizedBox(height: 16),
          
          //YARD CAPACITY HEATMAP
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Yard Capacity Heatmap',
                       style: TextStyle(
                        color: Color(0xFF0A2342),
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                      
                      ),
                      Text('Visual capacity map for port congestion',
                       style: TextStyle(
                        color: Color(0xFF0A2342),
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                      
                      ),
                      SizedBox(height: 14),
            
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                           _heatBox(Color(0xFFE53935)),
                           _heatBox(Color(0xFFEF5350)),
                           _heatBox(Color(0xFFFFD54F)),
                           _heatBox(Color(0xFFFFEB3B)),
                           _heatBox(Color(0xFF8BC34A)),
                           _heatBox(Color(0xFF4CAF50)),
                           _heatBox(Color(0xFFE53935)),
                           _heatBox(Color(0xFFFFC107)),
                           _heatBox(Color(0xFFCDDC39)),
                           _heatBox(Color(0xFF43A047)),
            
                        ],
                      ),
                      SizedBox(height: 4),
            
                      Row(
                       
                        children: [
                          Text('Low',
                           style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                           ),
                          ),
            
                          SizedBox(width: 290),
                         
                         Text('High',
                           style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                           ),
                          ),
                          
                        ],
                      )
                  
                      
                  
                     
                    ],
                  ),
            
                  Transform.translate(
                    offset: Offset(0,-10),
                    child: Container(
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
                        ),
                  ),
                ],
              ),
                
              
            ),
          ),

          SizedBox(height: 7),
          
          //ACTIVE BOOKING
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF0A2342),
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0,4)
                  )
                 ]
              ),
            
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(
                        'Active Booking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                       ),
            
                        Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF1D6F4E),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: Color(0xFF59E38C)),
                        SizedBox(width: 6),
                        Text('Approved',
                         style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                         ),
                        )
                      ],
                    ),
                   )
                     ],
                   ),
                   SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)
                    ),
            
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.confirmation_num_outlined,
                            color: Color(0xFF0A2342),),
            
                            SizedBox(width: 10),
            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                Text('Container',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text('TGBU123456',
                                  style: TextStyle(
                                    color: Color(0xFF0A2342),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                               ],
                            ),
                          ],
                        ),
            
                        SizedBox(height: 11),
                        Divider(height: 1),
                        SizedBox(height: 11),
                        Row(
                          children: [
                            Icon(Icons.event_outlined,
                            color: Color(0xFF0A2342),),
            
                            SizedBox(width: 10),
            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                Text('Appointment',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text('10:00 AM - 12:00 PM',
                                  style: TextStyle(
                                    color: Color(0xFF0A2342),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                               ],
                            ),
                          ],
                        ),
                        SizedBox(height: 11),
                        Divider(height: 1),
                        SizedBox(height: 11),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined,
                            color: Color(0xFF0A2342),),
            
                            SizedBox(width: 10),
            
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                Text('Gate',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text('GATE 18 - Main Entrance',
                                  style: TextStyle(
                                    color: Color(0xFF0A2342),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                               ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            
                  SizedBox(height: 12),
            
                //MAP
                 Container(
                  height: 80,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(16)
                  ),
                 ),
                  
              ],
            
              ),
            ),
          ),
            
            SizedBox(height: 9),

            //BUTTON
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(onPressed: (){
                   Navigator.push(context, 
                     MaterialPageRoute(builder: (context) => GatePassScreen(
                      qrToken: 'YOUR_QR_TOKEN_FROM_BACKEND',
                      gateName: 'GATE 18 - MAIN ENTRANCE',
                      scanText: 'Scan at Entrance',
                      status: 'Verified',
                      containerNumber: 'TGBU1234567',
                      timeWindow: '10:00 AM - 12:00 PM',
                      bookingRef: 'BK-987654',
                      ),
                      ),
                   );
              }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD700),
                  foregroundColor: Color(0xFF0A2342),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)
                  ),
                  elevation: 0,
                ),
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_2, color: Colors.black54, size: 30),
                  SizedBox(width: 9),
                  Text('VIEW GATE PASS',
                         style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                  
                         ),
                  ),
                ],
              )),
            ),
          )

          

          
        ],
      )),
          
          //BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedItemColor: const Color(0xFF0A2342),
        unselectedItemColor: Colors.grey,
          onTap:
           (index) {
            setState(() => _selectedIndex = index);

            if (index==0) {
              return;
            }

            /* if (index == 1){
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => ScanDocsScreen()));
            } */
            if (index == 2){
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyBookingsPage()));
            }
            /* if (index == 3){
              Navigator.push(
                context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            } */

            
           } ,


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


Widget _heatBox(Color color){
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(5),
    ),
  );
}