import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
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
  String? error;
  List<dynamic> bookings = [];

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
                    onPressed: loadBookings,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

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
                      onRefresh: loadBookings,
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
}

Widget _ticketCardFromApi(BuildContext context, Map<String, dynamic> booking) {
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
  );
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
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
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
              final status = (booking['status'] ?? '').toString().toLowerCase();

              if (status == 'approved') {
                final slot = booking['slot_detail'] ?? {};

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GatePassScreen(
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
                    builder: (context) => BookingDetailsPage(booking: booking),
                  ),
                );
              }
            },
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
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
