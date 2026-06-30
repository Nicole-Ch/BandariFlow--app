import 'package:bandariflow/views/admin/booking_detail.dart';
import 'package:bandariflow/views/admin/widgets/admin_bottom_nav.dart';
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

  List<dynamic> yardCapacities = [];
  bool loadingHeatmap = true;

  Future<void> loadYardActivity() async {
    try {
      final data = await ApiService.getYardCapacities();

      if (!mounted) return;

      setState(() {
        yardCapacities = data;
        loadingHeatmap = false;
      });
    } catch (_) {
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
                          "Today's Activity",
                          bookings.length.toString(),
                          Icons.timeline,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'Incoming Booking Requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),
                  ...bookings.map((booking) {
                    final status = (booking['status'] ?? '').toString();
                    final container =
                        booking['container_number']?.toString() ?? '--';
                    final slot = booking['slot_detail'] ?? {};
                    final gate = slot['gate']?['name']?.toString() ?? '--';
                    final start = slot['start_time']?.toString() ?? '--';
                    final end = slot['end_time']?.toString() ?? '--';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(container),
                        subtitle: Text(
                          '$gate • ${_formatTime(start)} - ${_formatTime(end)}',
                        ),
                        trailing: Text(status.toUpperCase()),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingDetailPage(booking: booking),
                            ),
                          ).then((_) {
                            // When they come back from the detail page, refresh the list
                            // so the approved item moves from Pending to Approved!
                            loadBookings();
                          });
                        },
                      ),
                    );
                  }),
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

String _formatTime(dynamic value) {
  if (value == null) return '--:--';
  final text = value.toString();
  if (text.length >= 16) return text.substring(11, 16);
  return text;
}
