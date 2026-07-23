import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverLogs extends StatefulWidget {
  const DriverLogs({super.key, required this.scanData});
  final Map<String, dynamic> scanData;

  @override
  State<DriverLogs> createState() => DriverLogsState();
}

class DriverLogsState extends State<DriverLogs> {
  @override
  Widget build(BuildContext context) {
    print("SCAN DATA:");
    print(widget.scanData);

    final booking = (widget.scanData['booking'] as Map<String, dynamic>?) ?? {};
    final driver = (booking['driver'] as Map<String, dynamic>?) ?? {};

    final slot = (booking['slot_detail'] as Map<String, dynamic>?) ?? {};

    final gate = (slot['gate'] as Map<String, dynamic>?) ?? {};
    final documents = booking['documents'] as List? ?? [];

    final driverName = driver['fullname'] ?? 'Unknown Driver';
    final idNumber = driver['id_number'] ?? '--';
    final phone = driver['phone'] ?? '--';
    final photo = driver['photo'];

    final truckPlate = driver['preferred_truck'] ?? '--';
    final shippingLine = booking['shippingline_detail']?['name'] ?? '--';
    final bookingDate =
        booking['created_at']?.toString().substring(0, 10) ?? '--';
    final slotTime = slot['start_time']?.toString().substring(11, 16) ?? '--';
    final gateName = gate['name'] ?? '--';

    final documentUrl = documents.isNotEmpty ? documents.first['file'] : null;

    return Scaffold(
      backgroundColor: Color(0xffF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff0A2342),
        foregroundColor: Colors.white,
        title: Text(
          "Driver Verification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            //STATUS
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.green),
              ),

              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.check, color: Colors.white),
                  ),

                  SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gate Pass Valid",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        SizedBox(height: 4),
                        Text(
                          "Please verify the driver's identity before allowing entry.",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 17),

            //DRIVER CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: Padding(
                padding: EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: photo != null
                          ? Image.network(
                              photo.toString().startsWith('http')
                                  ? photo
                                  : 'http://10.0.2.2:8000$photo',
                              width: 90,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 90,
                                height: 100,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.person, size: 50),
                              ),
                            )
                          : Container(
                              width: 90,
                              height: 100,
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.person, size: 50),
                            ),
                    ),

                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Driver ID :$idNumber",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Phone : $phone",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),

                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),

                            child: const Text(
                              "APPROVED BOOKING",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            //BOOKING DETAILS
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    buildRow(Icons.local_shipping, 'Truck Plate', truckPlate),
                    buildRow(Icons.anchor, 'Shipping Line', shippingLine),
                    buildRow(Icons.calendar_month, 'Booking Date', bookingDate),
                    buildRow(Icons.access_time, 'Slot', slotTime),
                    buildRow(Icons.location_pin, 'Gate', gateName),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DOCUMENTS
            documentUrl != null
                ? SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('VIEW VERIFICATION DOCUMENT'),
                      onPressed: () async {
                        final uri = Uri.parse(
                          documentUrl.toString().startsWith('http')
                              ? documentUrl
                              : 'http://10.0.2.2:8000$documentUrl',
                        );

                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                  )
                : const Text('No document uploaded'),

            const SizedBox(height: 10),

            Row(children: [Expanded(child: docCard("ID Copy"))]),
            SizedBox(height: 30),

            //BUTTONS
            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                onPressed: () {},

                icon: Icon(Icons.check),

                label: Text(
                  "ACCEPT ENTRY",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 56,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                onPressed: () {},

                icon: Icon(Icons.close),

                label: Text(
                  "REJECT ENTRY",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xff0A2342)),

        SizedBox(width: 14),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff145FCC),
          ),
        ),
      ],
    );
  }

  Widget docCard(String title) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(Icons.description, size: 40, color: Colors.green),

            SizedBox(height: 10),

            Text(title, textAlign: TextAlign.center),

            SizedBox(height: 10),

            Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
