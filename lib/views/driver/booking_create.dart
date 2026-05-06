import 'package:bandariflow/views/driver/driver_dashboard.dart';
import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:bandariflow/services/api_service.dart';

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
        backgroundColor: Color(0xFF0A2342),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DriverDashboard()),
            );
          },
        ),
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
                          width: 120,
                          height: 80,
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file_outlined, size: 22),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Upload Docs',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),

                                    maxLines: 1,
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
                //PICKUP DATE
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
                                    'Pickup Date',
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
                    SizedBox(width: 12),
                    //DELIVERY DATE
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
                                    'Delivery Date',
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  TextField(
                                    controller: deliveryDateController,
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

                SizedBox(height: 14),
                //CARGO TYPE
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
                                Icons.inventory_2,
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
                                    'Cargo Type',
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  TextField(
                                    controller: cargoTypeController,
                                    readOnly: true,
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Enter cargo description',
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
                    SizedBox(width: 12),
                    //CARGO TYPE
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
                                Icons.scale,
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
                                    'Cargo Weight',
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  TextField(
                                    controller: cargoWeightController,
                                    readOnly: true,
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Enter Weight (kg)',
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

                SizedBox(height: 14),

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
                          border: Border.all(color: Color(0xFFE1E7F0)),
                        ),
                        child: Icon(
                          Icons.notes_rounded,
                          color: Color(0xFF2F6FD6),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Special Instructions',
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(0xFFE1E7F0)),
                              ),
                              child: TextField(
                                controller: specialInstructionsController,
                                maxLines: 5,
                                style: TextStyle(
                                  color: Color(0xFF0A2342),
                                  fontSize: 15,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter any special instructions',
                                  hintStyle: TextStyle(color: Colors.black38),
                                  contentPadding: EdgeInsets.all(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 13),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2F6FD6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Booking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
    );
  }

  Future<void> submitBooking() async {
    try {
      final result = await ApiService.createBooking(
        slotId: 1, // replace with selected slot
        truckId: 1, // replace with selected truck
        shippingLineId: 1, // replace with selected shipping line
        containerNumber: shipperNameController.text.trim(),
        isEmpty: false,
        direction: 'import_pickup',
        manifestNumber: cargoTypeController.text.trim(),
        yardCapacityId: 1, // replace with selected yard capacity
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully')),
      );

      print(result);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
