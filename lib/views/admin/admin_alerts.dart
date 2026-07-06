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

  bool _isLoadingAlerts = false;
  bool _isLoadingGates = false;
  bool _isLoadingDrivers = false;

  Future<void> loadAlerts() async {
    if (_isLoadingAlerts) return;
    try {
      setState(() => _isLoadingAlerts = true);
      final alerts = await ApiService.getBroadcastAlerts();
      if (!mounted) return;
      setState(() {
        sentAlerts = alerts;
      });
    } catch (e) {
      debugPrint("Load Alerts Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingAlerts = false);
    }
  }

  Future<void> loadGates() async {
    if (_isLoadingGates) return;
    try {
      setState(() => _isLoadingGates = true);
      final data = await ApiService.getGates();
      if (!mounted) return;
      setState(() {
        gates = data;
      });
    } catch (e) {
      debugPrint("Load Gates Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingGates = false);
    }
  }

  Future<void> loadDrivers() async {
    if (_isLoadingDrivers) return;
    try {
      setState(() => _isLoadingDrivers = true);
      final data = await ApiService.getDrivers();
      if (!mounted) return;
      setState(() {
        driver = data;
      });
    } catch (e) {
      debugPrint("Load Drivers Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingDrivers = false);
    }
  }

  List<dynamic> sentAlerts = [];
  List<dynamic> gates = [];
  List<dynamic> driver = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadAlerts();
      await Future.delayed(const Duration(milliseconds: 300));
      await loadGates();
      await Future.delayed(const Duration(milliseconds: 300));
      await loadDrivers();
    });
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

            // 1. DYNAMIC DROPDOWN FOR SPECIFIC GATE
            if (selectedTarget == "Gate") ...[
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                initialValue: selectedGate,
                decoration: const InputDecoration(
                  labelText: "Select Target Gate",
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

            // ALL DRIVERS
            if (selectedTarget == "all") ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.campaign, color: Colors.blue.shade800, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Global Broadcast Active",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "This notification will hit all ${driver.length} registered system drivers simultaneously",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            //CUSTOM SELECTION
            if (selectedTarget == "Custom") ...[
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Select Targeted Drivers",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  if (_isLoadingDrivers)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (driver.isEmpty && !_isLoadingDrivers)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "No drivers loaded from your backend.",
                    style: TextStyle(color: Colors.red.shade400, fontSize: 13),
                  ),
                ),

              // We wrap the list in a constrained box with scrolling properties
              // so it never over-extends your page layout forms boundaries!
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      MediaQuery.of(context).size.height *
                      0.25, // Locks height to max 25% of the screen
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: driver.length,
                  itemBuilder: (context, index) {
                    final currentDriver = driver[index];

                    final String driverId = currentDriver["id"].toString();

                    String driverNames = "Port Driver #$driverId";

                    if (currentDriver["fullname"] != null &&
                        currentDriver["fullname"].toString().isNotEmpty) {
                      driverNames = currentDriver["fullname"].toString();
                    } else if (currentDriver["fullname"] != null &&
                        currentDriver["fullname"].toString().isNotEmpty) {
                      driverNames = currentDriver["fullname"].toString();
                    } else if (currentDriver["user"] != null &&
                        currentDriver["user"]["username"] != null) {
                      driverNames = currentDriver["user"]["username"]
                          .toString();
                    } else if (currentDriver["user_email"] != null) {
                      driverNames = currentDriver["user_email"].toString();
                    }

                    return CheckboxListTile(
                      activeColor: const Color(0xFF0D47A1),
                      contentPadding:
                          EdgeInsets.zero, // Eliminates padding leaks
                      title: Text(
                        driverNames,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: selectedDrivers.contains(driverId),
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            selectedDrivers.add(driverId);
                          } else {
                            selectedDrivers.remove(driverId);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],

            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: sendAlert,
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

                final String rawPriority = alert["priority"] ?? "Normal";
                final String targetAudience =
                    alert["target_role"]?.toString().toUpperCase() ?? "DRIVERS";

                // Formats Django '2026-07-06T05:47:38Z' timestamp down to a clean date string slice
                String alertTimestamp = "Recent";
                if (alert["sent_at"] != null) {
                  try {
                    alertTimestamp = alert["sent_at"].toString().substring(
                      0,
                      10,
                    ); // Extracts 'YYYY-MM-DD'
                  } catch (_) {}
                }
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
                                ).withAlpha(38),
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
                        Text(
                          alert["message"] ?? "",
                          style: TextStyle(fontSize: 15),
                        ),

                        SizedBox(height: 7),
                        Row(
                          children: [
                            Icon(Icons.group, size: 18, color: Colors.grey),
                            SizedBox(width: 5),

                            Text(
                              "Target: $targetAudience",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),

                            Spacer(),

                            Text(
                              alertTimestamp,
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
