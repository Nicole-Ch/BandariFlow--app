import 'package:flutter/material.dart';
import 'widgets/admin_bottom_nav.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

final TextEditingController titleController = TextEditingController();
final TextEditingController messageController = TextEditingController();
String priority = 'Normal';
String selectedTarget = 'all';

class _AlertsPageState extends State<AlertsPage> {
  @override
  final List<Map<String, dynamic>> sentAlerts = [
    {
      "title": "Heavy Traffic at Berth 8",
      "message":
          "Drivers are advised to use Gate 6 due to congestion at Berth 8.",
      "priority": "High",
      "target": "All Drivers",
      "time": "Today • 10:35 AM",
    },
    {
      "title": "Maintenance Notice",
      "message": "Gate 7 will close for maintenance at 3 PM.",
      "priority": "Normal",
      "target": "Gate 7",
      "time": "Yesterday • 5:12 PM",
    },
  ];
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Alerts"),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.campaign_rounded,
                  size: 30,
                  color: const Color.fromARGB(255, 74, 166, 242),
                ),
                SizedBox(width: 8),
                Text(
                  "Create New Alert",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            Text(
              "Title",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter alert title",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: 8),
            Text(
              "Message",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: "Type your message here",
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: 9),
            Text(
              "Priority",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),

            const SizedBox(height: 8),

            RadioGroup<String>(
              groupValue: priority, // Manages the selected radio value state
              onChanged: (String? value) {
                setState(() {
                  priority = value!;
                });
              },
              child: Wrap(
                spacing: 24,
                runSpacing: 12.0,
                children: const [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(value: "Low", activeColor: Colors.green),
                      Text("Low", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: "Normal",
                        activeColor: Colors.orange,
                      ),
                      Text("Normal", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(value: "High", activeColor: Colors.red),
                      Text("High", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 9),
            Text(
              "Send To",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),

            SizedBox(height: 12),

            //TARGET AUDIENCE
            RadioGroup<String>(
              groupValue:
                  selectedTarget, // Manages the selected radio value state
              onChanged: (String? value) {
                setState(() {
                  selectedTarget = value!;
                });
              },
              child: Wrap(
                spacing: 24,
                runSpacing: 12.0,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: "all",
                        activeColor: Color(0xFF0D47A1),
                      ),
                      Icon(Icons.group, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("All Drivers", style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: "Gate",
                        activeColor: Color(0xFF0D47A1),
                      ),
                      Icon(Icons.door_sliding, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("Specific Gate", style: TextStyle(fontSize: 15)),
                    ],
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: "Gate8",
                        activeColor: Color(0xFF0D47A1),
                      ),
                      Icon(Icons.people, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("Custom Selection", style: TextStyle(fontSize: 15)),
                    ],
                  ),

                  SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      label: Text(
                        "SEND ALERT",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2342),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}
