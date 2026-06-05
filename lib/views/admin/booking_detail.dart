import 'package:flutter/material.dart';
import 'package:bandariflow/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class BookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  bool isProcessing = false;

  String _formatDirection(dynamic value) {
    final text = value?.toString() ?? '';
    switch (text) {
      case 'import_pickup':
        return 'Import Pickup';
      case 'export_dropoff':
        return 'Export Drop-Off';
      case 'empty_return':
        return 'Empty Return';
      default:
        return text;
    }
  }

  // Function to call API and update status
  Future<void> _updateStatus(String decision) async {
    setState(() => isProcessing = true);

    try {
      await ApiService.updateBookingStatus(widget.booking['id'], decision);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking $decision successfully'),
          backgroundColor: decision == 'approved' ? Colors.green : Colors.red,
        ),
      );

      // Close the page and return to dashboard
      Navigator.pop(context);
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _viewDocument() async {
    final docs = (widget.booking['documents'] as List<dynamic>?) ?? [];

    if (docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No document attached to this booking")),
      );
      return;
    }

    final rawUrl = docs.first['file']?.toString();

    if (rawUrl == null || rawUrl.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Document link is missing")));
      return;
    }

    final uri = Uri.parse(
      rawUrl.startsWith('http') ? rawUrl : 'http://10.0.2.2:8000$rawUrl',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the document")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final slot = booking['slot_detail'] ?? {};
    final status = (booking['status'] ?? 'pending').toString().toLowerCase();
    final isPending = status == 'pending';
    final shippingLine = booking['shippingline_detail'] ?? {};
    final shippingLineName = shippingLine['name']?.toString() ?? 'Unknown';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('BK-${booking['id']} Review'),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Container No.', booking['container_number'] ?? '--'),
                    const Divider(),
                    _row(
                      'Cargo Type',
                      booking['cargo_type']?.toString() ?? 'Standard',
                    ),
                    const Divider(),
                    _row(
                      'Driver',
                      booking['driver']?['fullname']?.toString() ??
                          booking['driver']?['user']?['username']?.toString() ??
                          'Unknown',
                    ),

                    const Divider(),
                    _row('Shipping Line', shippingLineName),

                    const Divider(),
                    _row(
                      'Direction',
                      _formatDirection(booking['direction'] ?? 'import_pickup'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. SLOT DETAILS
            const Text(
              "Requested Slot",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF0A2342),
                ),
                title: Text(slot['gate']?['name'] ?? 'Gate --'),
                subtitle: Text("${slot['start_time']} - ${slot['end_time']}"),
              ),
            ),
            const SizedBox(height: 16),

            // 3. DOCUMENT VERIFICATION BUTTON
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.description),
                label: const Text("VIEW MANIFEST DOCUMENT"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  side: const BorderSide(color: Color(0xFF0A2342)),
                ),
                onPressed: _viewDocument,
              ),
            ),
            const SizedBox(height: 30),

            // 4. ACTION BUTTONS (Only show if Pending)
            if (isPending) ...[
              if (isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _updateStatus('rejected'),
                        child: const Text(
                          "REJECT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _updateStatus('approved'),
                        child: const Text(
                          "APPROVE",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ] else ...[
              // If already approved/rejected, show a static label
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: status == 'approved'
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                child: Text(
                  "This booking is ${status.toUpperCase()}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status == 'approved' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color.fromARGB(255, 65, 62, 62),
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
