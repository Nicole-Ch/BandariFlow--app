import 'package:flutter/material.dart';
import 'widgets/admin_bottom_nav.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Alerts"),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Admin Profile",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
    );
  }
}
/* const SizedBox(height: 12),
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
                  } */