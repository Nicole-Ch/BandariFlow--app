import 'package:flutter/material.dart';

class BookingDetailsPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final slot = booking['slot_detail'] ?? {};
    final gateName = slot['gate']?['name']?.toString() ?? 'Gate';
    final containerNo = booking['container_number']?.toString() ?? '';
    final status = booking['status']?.toString() ?? '';
    final bookingRef = 'BK-${booking['id']}';

    // Normalize the status string to make comparisons reliable
    final cleanStatus = status.trim().toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Booking Details'),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gateName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0A2342),
                ),
              ),
              const SizedBox(height: 12),
              Text('Booking Ref: $bookingRef'),
              const SizedBox(height: 8),
              Text('Container: $containerNo'),
              const SizedBox(height: 8),
              Text('Status: $status'),
              const SizedBox(height: 12),

              if (cleanStatus == 'approved') ...[
                Text(
                  'QR Token: ${booking['qr_token'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ] else ...[
                const Text(
                  'QR Pass will be available once your booking is approved.',
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
