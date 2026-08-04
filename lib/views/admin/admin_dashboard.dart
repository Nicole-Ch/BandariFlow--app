import 'package:bandariflow/views/admin/widgets/admin_bottom_nav.dart';
import 'package:bandariflow/views/gate/scan_history_page.dart';
import 'package:flutter/material.dart';
import 'package:bandariflow/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> bookings = [];
  bool loading = true;
  String? error;
  List<dynamic> gateScans = [];
  bool loadingGateScans = true;

  List<dynamic> yardCapacities = [];
  bool loadingHeatmap = true;
  Future<void> loadYardActivity() async {
    try {
      print("Loading yard capacities...");

      final data = await ApiService.getYardCapacities();

      print("Received ${data.length} yard capacity records");
      if (!mounted) return;
      setState(() {
        yardCapacities = data;
        loadingHeatmap = false;
      });
    } catch (e) {
      print("Yard capacity error: $e");

      if (!mounted) return;
      setState(() {
        loadingHeatmap = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadBookings();
    loadYardActivity();
    loadGateScans();
  }

  Future<void> loadBookings() async {
    try {
      final data = await ApiService.getBookings();
      if (!mounted) return;
      setState(() {
        bookings = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  List<dynamic> get pendingBookings => bookings
      .where((b) => (b['status'] ?? '').toString().toLowerCase() == 'pending')
      .toList();

  List<dynamic> get approvedBookings => bookings
      .where((b) => (b['status'] ?? '').toString().toLowerCase() == 'approved')
      .toList();

  int get todaysScans {
    final today = DateTime.now();

    return gateScans.where((scan) {
      if (scan["scanned_at"] == null) return false;

      final scannedDate = DateTime.parse(scan["scanned_at"]);

      return scannedDate.year == today.year &&
          scannedDate.month == today.month &&
          scannedDate.day == today.day;
    }).length;
  }

  Future<void> _Logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you really want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> loadGateScans() async {
    try {
      final data = await ApiService.getGateScanLogs();

      if (!mounted) return;

      setState(() {
        gateScans = data;
        loadingGateScans = false;
      });
    } catch (e) {
      debugPrint("Gate Scan Error: $e");

      if (!mounted) return;

      setState(() {
        loadingGateScans = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _Logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : RefreshIndicator(
              onRefresh: loadBookings,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _summaryCard(
                    'Pending',
                    pendingBookings.length,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  _summaryCard(
                    'Approved',
                    approvedBookings.length,
                    Colors.green,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Yard Activity Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A2342),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          "Pending",
                          pendingBookings.length.toString(),
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          "Approved",
                          approvedBookings.length.toString(),
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          "Total Bookings",
                          bookings.length.toString(),
                          Icons.local_shipping,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _statCard(
                          "Today's Gate Scans",
                          todaysScans.toString(),
                          Icons.qr_code_scanner,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _buildScanLogsCard(),

                  const SizedBox(height: 25),

                  const Text(
                    "Current Yard Utilization",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  if (loadingHeatmap)
                    const Center(child: CircularProgressIndicator())
                  else
                    _yardUtilizationCard(),
                ],
              ),
            ),

      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            '$count',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _yardUtilizationCard() {
    if (yardCapacities.isEmpty) {
      return const Center(child: Text("No yard capacity data available."));
    }

    final Map<String, Map<String, int>> gateStats = {};

    for (final yard in yardCapacities) {
      final gateName = yard["gate"]["name"];

      gateStats.putIfAbsent(gateName, () => {"total": 0, "reserved": 0});

      gateStats[gateName]!["total"] =
          gateStats[gateName]!["total"]! + (yard["quota_total"] as int);

      gateStats[gateName]!["reserved"] =
          gateStats[gateName]!["reserved"]! + (yard["quota_reserved"] as int);
    }

    return Column(
      children: gateStats.entries.map((entry) {
        final total = entry.value["total"]!;
        final reserved = entry.value["reserved"]!;
        final percent = total == 0 ? 0.0 : reserved / total;

        Color progressColor;

        if (percent >= 0.8) {
          progressColor = Colors.red;
        } else if (percent >= 0.6) {
          progressColor = Colors.orange;
        } else {
          progressColor = Colors.green;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black12)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "${(percent * 100).toStringAsFixed(1)}% occupied",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: percent,
                minHeight: 12,
                borderRadius: BorderRadius.circular(20),
                color: progressColor,
              ),

              const SizedBox(height: 10),

              Text("$reserved of $total slots occupied"),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildScanLogsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScanHistoryPage()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2342).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.history,
                  size: 28,
                  color: Color(0xFF0A2342),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'View Scan Logs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A2342),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete gate scan history and validation logs',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2342),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'VIEW LOGS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatTime(dynamic value) {
  if (value == null) return '--:--';
  final text = value.toString();
  if (text.length >= 16) return text.substring(11, 16);
  return text;
}
