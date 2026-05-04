import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';

class BookingCreate extends StatefulWidget {
  const BookingCreate({super.key});

  @override
  State<BookingCreate> createState() => _BookingCreateState();
}

class _BookingCreateState extends State<BookingCreate> {
  final shipperNameController = TextEditingController();
  final pickupLocationController = TextEditingController();
  final dropoffLocationController = TextEditingController();
  final pickupDateController = TextEditingController();
  final deliveryDateController = TextEditingController();
  final cargoTypeController = TextEditingController();
  final cargoWeightController = TextEditingController();
  final freightCostController = TextEditingController();
  final specialInstructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Create Booking'),
        centerTitle: true,
        backgroundColor: Color(0xFF0D3B8E),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFFE1E7F0)),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          'assets/images/Truck.jpg',
                          width: 150,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),

                      SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 47,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2F6FD6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file_outlined, size: 26),
                                SizedBox(width: 10),
                                Text(
                                  'Upload Documents',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 18),
                Divider(height: 1),
                SizedBox(height: 18),

                //SHIPPERS NAME
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE1E7F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F4FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Color(0xFF2F6FD6),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shipper Name',
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3),
                            TextField(
                              controller: shipperNameController,
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter shipper name',
                                hintStyle: TextStyle(color: Colors.black38),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14),

                //PICKUP LOCATION
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE1E7F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F4FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.apartment,
                          color: Color(0xFF2F6FD6),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup Location',
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3),
                            TextField(
                              controller: pickupLocationController,
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter Pickup location',
                                hintStyle: TextStyle(color: Colors.black38),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14),

                //DROP OFF LOCATION
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFE1E7F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(0xFFF0F4FA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Color(0xFF2F6FD6),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Drop-off Location',
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3),
                            TextField(
                              controller: dropoffLocationController,
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter drop-off location',
                                hintStyle: TextStyle(color: Colors.black38),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Color(0xFFF8FAFD),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Color(0xFFE1E7F0)),
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Color(0xFFF8FAFD),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Color(0xFFE1E7F0)),
                              ),
                              child: Icon(
                                Icons.calendar_month,
                                color: Color(0xFF2F6FD6),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'pickup Date',
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  TextField(
                                    controller: pickupDateController,
                                    readOnly: true,
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Select date',
                                      hintStyle: TextStyle(
                                        color: Colors.black38,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
    );
  }
}
