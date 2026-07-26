import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bandariflow/views/driver/booking_details_page.dart';
import 'package:bandariflow/views/driver/gate_pass_screen.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  int selectedTab = 0;
  bool loading = true;
  bool offlineMode = false;
  String? error;
  List<dynamic> bookings = [];

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final connectivity = await Connectivity().checkConnectivity();

      final isOffline = connectivity.contains(ConnectivityResult.none);

      if (isOffline) {
        final cached = prefs.getString('cached_bookings');

        if (cached != null) {
          bookings = jsonDecode(cached);
        }

        if (!mounted) return;

        setState(() {
          offlineMode = true;
          loading = false;
        });

        return;
      }

      final data = await ApiService.getBookings();

      await prefs.setString('cached_bookings', jsonEncode(data));

      if (!mounted) return;

      setState(() {
        bookings = data;
        loading = false;
        offlineMode = false;
      });
    } catch (e) {
      final cached = prefs.getString('cached_bookings');

      if (cached != null) {
        bookings = jsonDecode(cached);
      }

      if (!mounted) return;

      setState(() {
        offlineMode = true;
        loading = false;
      });
    }
  }

  List<dynamic> get activeBookings {
    return bookings.where((b) {
      final status = (b['status'] ?? '').toString().toLowerCase();
      return status == 'pending' || status == 'approved' || status == 'arrived';
    }).toList();
  }

  List<dynamic> get pastBookings {
    return bookings.where((b) {
      final status = (b['status'] ?? '').toString().toLowerCase();
      return status == 'used' || status == 'cancelled' || status == 'rejected';
    }).toList();
  }

  Future<void> _cancelBooking(int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ApiService.cancelBooking(bookingId);

      await loadBookings(); // refresh the list
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentList = selectedTab == 0 ? activeBookings : pastBookings;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 2),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(color: Color(0xFF0A2342)),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Text(
                    'My Tickets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: offlineMode ? null : loadBookings,
                    icon: Icon(
                      Icons.refresh,
                      color: offlineMode ? Colors.white54 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            if (offlineMode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "You're offline. You can still view your saved passes.",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = 0;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedTab == 0
                                ? const Color(0xFFD8E9FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Active',
                            style: TextStyle(
                              color: selectedTab == 0
                                  ? const Color(0xFF0A2342)
                                  : Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTab = 1;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedTab == 1
                                ? const Color(0xFFD8E9FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Past',
                            style: TextStyle(
                              color: selectedTab == 1
                                  ? const Color(0xFF0A2342)
                                  : Colors.black54,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                  ? Center(child: Text(error!))
                  : RefreshIndicator(
                      onRefresh: () async {
                        if (!offlineMode) {
                          await loadBookings();
                        }
                      },
                      child: currentList.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 140),
                                Center(
                                  child: Text(
                                    'No bookings found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: currentList.length,
                              itemBuilder: (context, index) {
                                final booking = currentList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: selectedTab == 0
                                      ? _ticketCardFromApi(context, booking)
                                      : _pastTicketCardFromApi(booking),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketCardFromApi(
    BuildContext context,
    Map<String, dynamic> booking,
  ) {
    final status = (booking['status'] ?? '').toString().toLowerCase();
    final containerNo = booking['container_number']?.toString() ?? '—';
    final bookingRef = 'BK-${booking['id']}';
    final slot = booking['slot_detail'] ?? {};
    final gate = slot['gate']?['name']?.toString() ?? 'Gate';
    final startTime = _formatTime(slot['start_time']);
    final endTime = _formatTime(slot['end_time']);
    final timeWindow = '$startTime - $endTime';
    final bookingDate = _formatDate(slot['start_time']);

    Color statusColor;
    String statusText;
    switch (status) {
      case 'approved':
        statusColor = const Color(0xFF1B8F3A);
        statusText = 'VERIFIED';
        break;
      case 'pending':
        statusColor = const Color(0xFFF39C12);
        statusText = 'PENDING';
        break;
      case 'arrived':
        statusColor = const Color(0xFF2F6FD6);
        statusText = 'ARRIVED';
        break;
      default:
        statusColor = const Color(0xFF8E96A8);
        statusText = status.toUpperCase();
    }

    return _ticketCard(
      context: context,
      gate: gate,
      containerNo: containerNo,
      timeWindow: timeWindow,
      bookingDate: bookingDate,
      bookingRef: bookingRef,
      statusText: statusText,
      statusColor: statusColor,
      buttonText: status == 'approved' ? 'View Pass' : 'View Details',
      buttonColor: status == 'approved'
          ? const Color(0xFF2F6FD6)
          : const Color(0xFFF39C12),
      booking: booking,
      onCancel: () => _cancelBooking(booking['id']),
    );
  }
}

Widget _pastTicketCardFromApi(Map<String, dynamic> booking) {
  final status = (booking['status'] ?? '').toString().toLowerCase();
  final containerNo = booking['container_number']?.toString() ?? '—';
  final bookingRef = 'BK-${booking['id']}';

  final slot = booking['slot_detail'] ?? {};
  final gate = slot['gate']?['name']?.toString() ?? 'Gate';
  final startTime = _formatDate(slot['start_time']);
  final statusColor = status == 'cancelled'
      ? const Color(0xFFE74C3C)
      : const Color(0xFF8E96A8);

  return _pastTicketCard(
    gate: gate,
    containerNo: containerNo,
    date: startTime,
    bookingRef: bookingRef,
    statusText: status.toUpperCase(),
    statusColor: statusColor,
  );
}

Widget _ticketCard({
  required BuildContext context,
  required Map<String, dynamic> booking,
  required String gate,
  required String containerNo,
  required String timeWindow,
  required String bookingRef,
  required String statusText,
  required Color statusColor,
  required String buttonText,
  required Color buttonColor,
  required String bookingDate,
  VoidCallback? onCancel,
}) {
  final status = (booking['status'] ?? '').toString().toLowerCase();
  final showCancel =
      status == 'pending'; // only pending bookings can be cancelled

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: Stack(
      children: [
        // Main card content (unchanged)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gate,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0A2342),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Container No: $containerNo',
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 95,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: buttonColor,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Window: $timeWindow',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: $bookingDate',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  if (status == 'approved') {
                    final slot = booking['slot_detail'] ?? {};
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GatePassScreen(
                          qrToken: booking['qr_token']?.toString() ?? '',
                          gateName: slot['gate']?['name']?.toString() ?? '',
                          scanText: 'Scan at Entrance',
                          status: booking['status']?.toString() ?? '',
                          containerNumber:
                              booking['container_number']?.toString() ?? '',
                          timeWindow:
                              '${_formatTime(slot['start_time'])} - ${_formatTime(slot['end_time'])}',
                          bookingRef: 'BK-${booking['id']}',
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailsPage(booking: booking),
                      ),
                    );
                  }
                },
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Cancel button (top‑right)
        if (showCancel)
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              tooltip: 'Cancel Booking',
              onPressed: onCancel,
            ),
          ),
      ],
    ),
  );
}

Widget _pastTicketCard({
  required String gate,
  required String containerNo,
  required String date,
  required String bookingRef,
  required String statusText,
  required Color statusColor,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gate,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A2342),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Container No: $containerNo',
          style: const TextStyle(fontSize: 15, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 95,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(Icons.history, color: statusColor, size: 36),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: $date',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A2342),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Booking Ref: $bookingRef',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A2342),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

String _formatDate(dynamic value) {
  if (value == null) return '--';
  final text = value.toString();
  if (text.length >= 10) return text.substring(0, 10);
  return text;
}
