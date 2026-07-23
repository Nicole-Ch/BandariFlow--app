import 'package:flutter/material.dart';

class DriverLogs extends StatefulWidget {
  const DriverLogs({super.key});

  @override
  State<DriverLogs> createState() => DriverLogsState();
}

class DriverLogsState extends State<DriverLogs> {
  @override
  Widget build(BuildContext context) {
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
                    ClipRect(
                      child: Container(
                        width: 90,
                        height: 100,
                        child: Icon(Icons.person),
                      ),
                    ),

                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pendo Jacky",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Driver ID : 38902862",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Phone : 0775261902",
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
                    buildRow(Icons.local_shipping, "Truck Plate", "KDA 184Z"),

                    Divider(),

                    buildRow(Icons.anchor, "Shipping Line", "MSC"),

                    Divider(),

                    buildRow(
                      Icons.calendar_month,
                      "Booking Date",
                      "21 July 2026",
                    ),

                    Divider(),

                    buildRow(Icons.access_time, "Slot", "09:00 AM"),

                    Divider(),

                    buildRow(Icons.location_pin, "Gate", "Gate 2"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // DOCUMENTS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Verified Documents",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: docCard("ID Copy")),

                SizedBox(width: 10),

                Expanded(child: docCard("Manifest")),

                SizedBox(width: 10),

                Expanded(child: docCard("Invoice")),
              ],
            ),
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
