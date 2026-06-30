import 'package:flutter/material.dart';
import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/admin/booking_detail.dart';
import 'widgets/admin_bottom_nav.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookings"),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : RefreshIndicator(
              onRefresh: loadBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];

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
                      trailing: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: status == "approved"
                              ? Colors.green
                              : status == "pending"
                              ? Colors.orange
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingDetailPage(booking: booking),
                          ),
                        ).then((_) {
                          loadBookings();
                        });
                      },
                    ),
                  );
                },
              ),
            ),

      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}

String _formatTime(dynamic value) {
  if (value == null) return '--:--';

  final text = value.toString();

  if (text.length >= 16) {
    return text.substring(11, 16);
  }

  return text;
}
