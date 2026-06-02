import 'package:flutter/material.dart';
import 'package:bandariflow/services/api_service.dart';

class BookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  bool isProcessing = false;

  // Function to call API and update status
  Future<void> _updateStatus(String decision) async {
    setState(() => isProcessing = true);

    try {
      // Calls your backend: /api/bookings/{id}/update_status/
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

  void _viewDocument() {
    // Check if a URL exists. If your backend sends a full URL, use it directly.
    final url = widget.booking['manifest_url'];

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No document attached to this booking")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text("Cargo Manifest"),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(
              height: 400,
              width: double.infinity,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (ctx, error, stack) => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      Text("Could not load image"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final slot = booking['slot_detail'] ?? {};
    final status = (booking['status'] ?? 'pending').toString().toLowerCase();
    final isPending = status == 'pending';

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
                    _row('Cargo Type', booking['cargo_type'] ?? 'Standard'),
                    const Divider(),
                    _row('Driver', booking['driver_name'] ?? 'Unknown'),
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
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
