import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';



class GatePassScreen extends StatelessWidget {

  final String qrToken;
  final String gateName;
  final String scanText;
  final String status;
  final String containerNumber;
  final String timeWindow;
  final String bookingRef;

  const GatePassScreen({
    super.key,
    required this.qrToken, required this.gateName, required this.scanText, required this.status, required this.containerNumber, required this.timeWindow, required this.bookingRef,
  });
  

  @override
  Widget build(BuildContext context) {

    Color statusColor;
    Color statusBg;

    switch (status.toLowerCase()) {
      case 'verified':
         statusColor = Color(0xFF1B8F3A);
         statusBg = Color(0xFFE7F8EC);
         break;

      case 'rejected':
         statusColor = Color(0xFFB7791F);
         statusBg = Color.fromARGB(255, 190, 40, 10);
            
        
        break;

      default:
       statusColor = Color(0xFFB7791f);
       statusBg = Color(0xFFFFF3D9);
    }
    
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [

                //TOB BAR
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2342),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                     Icon(Icons.anchor, color: Colors.white, size: 26,),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0A2342),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0,4)
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GATE PASS',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),

                      SizedBox(height: 8),
                      Text(gateName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 6),
                      Text(scanText,
                       style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,

                       ),
                      
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow:[ BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0,4),
                    )]
                  ),

                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0,2),
                            ),
                          ],
                        ),

                        child: QrImageView(
                          data: qrToken,
                          version: QrVersions.auto,
                          size: 200,
                          backgroundColor: Colors.white,
                          
                          ),
                      ),

                      SizedBox(height: 18),

                      //VERIFIED / REJECTED
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical:10),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status.toLowerCase() == 'rejected'? Icons.close_rounded : Icons.check_circle,
                              color: statusColor,
                              size: 24,
                              ),

                              SizedBox(width: 8),

                              Text(status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                          ],
                        ),

                        
                      ),

                      SizedBox(height: 18),
                      Divider(height: 1),
                      SizedBox(height: 14),
                      

                      Row(
                        
                        children: [
                          
                          SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              
                              children: [
                                Icon(Icons.access_time, color: Color(0xFF0A2342)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Time Window:',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text('10:00 AM - 12:00 PM',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                           
                            Container(
                              height: 32, 
                              width: 1,
                              color: Colors.grey,
                        ),
                       
                       SizedBox(width: 15),

                       

                        Expanded(
                          child: Row(
                           
                            children: [
                              Icon(Icons.confirmation_num_outlined, color: Color(0xFF0A2342)),
                              SizedBox(width: 9),
                              Column(
                               
                                children: [
                                  Text('Booking Ref',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 14,
                                    ),
                                  ),
                              
                                  SizedBox(height: 2),
                              Text(bookingRef,
                               style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                               ),
                              )
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                          
                            

                        ],
                      )
                    ],
                  ),

                )
              ],
            ),
          ),
        )),
    );
  }
}