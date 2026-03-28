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
         statusBg = Color(0xFFFFF3D9);
            
        
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Color(0xFF0A2342),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      
                    ),
                  ),

                  child: Row(
                    children: [
                      Icon(Icons.anchor, color: Colors.white, size: 26,),
                      SizedBox(width: 8,),
                      Text(
                        'BandariFlow',
                        style: TextStyle(
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
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF0A2342),
                        ),
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