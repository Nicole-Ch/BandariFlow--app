import 'package:bandariflow/services/api_service.dart';
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

String? selectedGate;
List<String> selectedDrivers = [];

class _AlertsPageState extends State<AlertsPage> {
  @override
  final List<Map<String, dynamic>> gates = [
    {"id": 1, "name": "Berth 8 Gate"},
    {"id": 2, "name": "Gate 6"},
    {"id": 3, "name": "Gate 7"},
    {"id": 4, "name": "Shimanzi Gate"},
  ];

  final List<Map<String, dynamic>> drivers = [
    {"id": 1, "fullname": "John Mwangi"},
    {"id": 2, "fullname": "Brian Otieno"},
    {"id": 3, "fullname": "James Kiptoo"},
    {"id": 4, "fullname": "Faith Achieng"},
  ];
  Color priorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Low":
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Future<void> sendAlert() async {
    try {
      await ApiService.sendBroadcastAlert(
        title: titleController.text,
        message: messageController.text,
        priority: priority,

        targetRole: selectedTarget == "all" ? "driver" : null,

        gateId: selectedTarget == "Gate" ? int.parse(selectedGate!) : null,
      );

      titleController.clear();
      messageController.clear();

      selectedGate = null;
      selectedDrivers.clear();

      await loadAlerts();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Alert sent successfully")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> loadAlerts() async {
    try {
      final alerts = await ApiService.getBroadcastAlerts();

      setState(() {
        sentAlerts = alerts;
      });
    } catch (e) {
      debugPrint("Load Alerts Error: $e");
    }
  }

  List<dynamic> sentAlerts = [];

  @override
  void initState() {
    super.initState();
    loadAlerts();
  }

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
            onPressed: sendAlert,
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
                        value: "Custom",
                        activeColor: Color(0xFF0D47A1),
                      ),
                      Icon(Icons.people, size: 18, color: Colors.grey),
                      SizedBox(width: 6),
                      Text("Custom Selection", style: TextStyle(fontSize: 15)),
                    ],
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ),

            if (selectedTarget == "Gate") ...[
              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: selectedGate,
                decoration: const InputDecoration(
                  labelText: "Select Gate",
                  border: OutlineInputBorder(),
                ),

                items: gates.map((gate) {
                  return DropdownMenuItem<String>(
                    value: gate["id"].toString(),
                    child: Text(gate["name"]),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedGate = value;
                  });
                },
              ),
            ],

            if (selectedTarget == "Custom") ...[
              const SizedBox(height: 15),

              const Text(
                "Select Drivers",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),

              const SizedBox(height: 10),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final driver = drivers[index];

                  return CheckboxListTile(
                    title: Text(driver["fullname"]),

                    value: selectedDrivers.contains(driver["id"].toString()),

                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          selectedDrivers.add(driver["id"].toString());
                        } else {
                          selectedDrivers.remove(driver["id"].toString());
                        }
                      });
                    },
                  );
                },
              ),
            ],

            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                label: Text(
                  "SEND ALERT",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

            SizedBox(height: 15),
            Divider(),
            SizedBox(height: 10),

            Row(
              children: [
                Icon(Icons.history, color: Color(0xFF0A2342)),
                SizedBox(width: 8),
                Text(
                  "Previously Sent Alerts",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 9),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: sentAlerts.length,
              itemBuilder: (context, index) {
                final alert = sentAlerts[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              color: priorityColor(alert["priority"]),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                alert["title"] ?? "No Title",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor(
                                  alert["priority"],
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),

                              child: Text(
                                alert["priority"],
                                style: TextStyle(
                                  color: priorityColor(alert["priority"]),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),
                        Text(alert["message"], style: TextStyle(fontSize: 15)),

                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.group, size: 18, color: Colors.grey),
                            SizedBox(width: 5),

                            Text(
                              alert['target'],
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),

                            Spacer(),

                            Text(
                              alert["time"],
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
    );
  }
}
