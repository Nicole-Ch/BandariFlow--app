import 'package:flutter/material.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {

  int selectedTab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child:  Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical:14),
              decoration: BoxDecoration(
                color: Color(0xFF0A2342),
                
              ),

              child: Row(
                children: [
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.arrow_back, color: Colors.white,),
                  
                  ),

                  SizedBox(width: 10),
                  Text('My Tickets',
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                  ),

                  Spacer(),

                  Icon(Icons.notifications, color: Colors.white, size: 30)

                  
                ],
              ),
            ),

            SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
              
                child: Row(
                  children: [
                    Expanded(child: GestureDetector(
                      onTap: (){
                        setState(() {
                          selectedTab = 0;
                        });
                      },
              
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedTab == 0 ? Color(0xFFD8E9FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
              
                        alignment: Alignment.center,
                        child: Text('Active',
                            style: TextStyle(
                              color: selectedTab == 0 ? Color(0xFF0A2342) : Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                        ),
                      ),
                    ),
                    ),

                    Expanded(child: GestureDetector(
                      onTap: (){
                        setState(() {
                          selectedTab = 1;
                        });
                      },
              
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedTab == 1 ? Color(0xFFD8E9FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
              
                        alignment: Alignment.center,
                        child: Text('Past',
                            style: TextStyle(
                              color: selectedTab == 1 ? Color(0xFF0A2342) : Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                        ),
                      ),
                    ),
                    ),

                    
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: selectedTab == 0 ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Bookings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0A2342),
                      ),
                    ),

                    SizedBox(height: 14),

                    _ticketCard(
                      gate: 'Gate 18',
                      containerNo: 'TGBU1234567',
                      timeWindow: '10:00 AM - 12:00 PM',
                      bookingRef: 'BK-987654',
                      statusText: 'APPROVED',
                      statusColor: const Color(0xFF1B8F3A),
                      buttonText: 'View Pass',
                      buttonColor: const Color(0xFF2F6FD6),),

                      SizedBox(height: 14),

                      _ticketCard(
                        gate: 'Gate C1',
                        containerNo: 'XYZ987654321',
                        timeWindow: '1:00 PM - 3:00 PM',
                        bookingRef: 'BK-10567',
                        statusText: 'AWAITING APPROVAL',
                        statusColor: const Color(0xFFF39C12),
                        buttonText: 'View Details',
                        buttonColor: const Color(0xFFF39C12),)
                  ],
              ) : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Past Bookings',
                   style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0A2342),
                   ),
                  ),

                  SizedBox(height: 14),
                    _pastTicketCard(
                            gate: 'Gate B4',
                            containerNo: 'LMN11223344',
                            date: 'April 10, 2024',
                            bookingRef: 'BK-09876',
                            statusText: 'COMPLETED',
                            statusColor: const Color(0xFF8E96A8),
                          ),

                          SizedBox(height: 14),
                          _pastTicketCard(
                            gate: 'Gate A1',
                            containerNo: 'PQRS56789012',
                            date: 'March 22, 2024',
                            bookingRef: 'BK-07654',
                            statusText: 'CANCELLED',
                            statusColor: const Color(0xFFE74C3C),
                          ),
                ],
              )

            )
            )



          ],
        )
      )
    );
  }
}

Widget _ticketCard({
  required String gate,
  required String containerNo,
  required String timeWindow,
  required String bookingRef,
  required String statusText,
  required Color statusColor,
  required String buttonText,
  required Color buttonColor,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
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
        Text(gate,
         style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0A2342),
         ),
        ),

        SizedBox(height: 6),
        Text('Container No: $containerNo',
           style: TextStyle(
            fontSize: 15,
            color: Colors.black54,
           ),
        ),
        SizedBox(height: 12),
        Divider(height: 1),
        SizedBox(height: 12),

        Row(children: [
          Container(
            width: 95,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFEAF1FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(Icons.map_outlined, color: buttonColor, size: 36,),
            ),
          ),
          SizedBox(width: 12,),

          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time Window: $timeWindow',
                style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A2342),
              ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ))
        ],
        ),

        SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: (){
               
          }, child: Text(buttonText,
               style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
               ),
          )),
        )
      ],
    ),
  );
}

Widget _pastTicketCard({
    required String gate,
    required String containerNo,
    required String date,
    required String bookingRef,
    required String statusText,
    required Color statusColor,
  }) {
    return Container(
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
          Text(
            gate,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0A2342),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Container No: $containerNo',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 95,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    Icons.history,
                    color: statusColor,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: $date',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2342),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Booking Ref: $bookingRef',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2342),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
