import 'package:bandariflow/views/admin/booking_detail.dart';
import 'package:flutter/material.dart';
import 'package:bandariflow/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> bookings = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadBookings();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
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
                    'Incoming Bookings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0A2342),
                    ),
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
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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

String _formatTime(dynamic value) {
  if (value == null) return '--:--';
  final text = value.toString();
  if (text.length >= 16) return text.substring(11, 16);
  return text;
}
