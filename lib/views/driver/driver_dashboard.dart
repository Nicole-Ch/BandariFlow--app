import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/driver/gate_pass_screen.dart';
import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  List<dynamic> bookings = [];
  Map<String, dynamic>? activeBooking;
  bool loading = true;

  Timer? _countdownTimer;
  String _hoursStr = '00';
  String _minutesStr = '00';
  String _secondsStr = '00';
  Position? _currentPosition;
  bool _loadingLocation = true;
  List<dynamic> yardCapacities = [];
  bool loadingHeatmap = true;

  @override
  void dispose() {
    _countdownTimer?.cancel(); //  stops running in background when page closes
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadDashboardData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentLocation();
      loadHeatmapData();
    });
  }

  Future<void> _loadCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint(
          "GPS hardware services are completely turned off on this device.",
        );
        setState(() => _loadingLocation = false);
        return;
      }
      LocationPermission permission =
          await Geolocator.checkPermission(); //asks device if the app already has location access

      if (permission == LocationPermission.denied) {
        //checks if user denied location access in teh past
        permission =
            await Geolocator.requestPermission(); //triggers pop up dialog box asking user to grant location access
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() => _loadingLocation = false);
        return;
      }

      // request position data with a hard structural timeout safety net
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).timeout(
            const Duration(
              seconds: 5,
            ), // If GPS fails to respond in 5s, drop out
            onTimeout: () async {
              // Fallback: Grab the last known location stored by the handset cache instead
              final lastKnown = await Geolocator.getLastKnownPosition();
              if (lastKnown != null) return lastKnown;

              // Provide fallback mock coordinates for Nairobi if everything fails
              return Position(
                latitude: -1.2921, // Nairobi Latitude
                longitude: 36.8219, // Nairobi Longitude
                timestamp: DateTime.now(),
                accuracy: 1.0,
                altitude: 1795.0,
                altitudeAccuracy: 1.0,
                heading: 0.0,
                headingAccuracy: 1.0,
                speed: 0.0,
                speedAccuracy: 1.0,
              );
            },
          );

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _loadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingLocation = false);
    }
  }

  Future<void> loadDashboardData() async {
    try {
      final data = await ApiService.getBookings();
      Map<String, dynamic>? approvedBooking;

      for (final b in data) {
        final status = (b['status'] ?? '').toString().toLowerCase();
        if (status == 'approved') {
          approvedBooking = Map<String, dynamic>.from(b);
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        bookings = data;
        activeBooking = approvedBooking;
        loading = false;
      });

      if (approvedBooking != null) {
        _startCountdown(approvedBooking['slot_detail']?['start_time']);
      }

      // Check for broadcast alerts right after loading completes
      await checkForBroadcastAlerts();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        activeBooking = null;
      });
    }
  }

  Future<void> checkForBroadcastAlerts() async {
    try {
      final List<dynamic> alerts = await ApiService.getBroadcastAlerts();

      if (alerts.isEmpty || !mounted) return;

      final latestAlert = alerts.first;
      final int latestId = int.tryParse(latestAlert['id'].toString()) ?? 0;

      final prefs = await SharedPreferences.getInstance();
      final int lastSeenId = prefs.getInt('last_seen_alert_id') ?? 0;

      if (latestId <= lastSeenId) {
        return; // already shown before
      }

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF0A2342),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.verified, color: Color(0xFF59E38C), size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    latestAlert['title'] ?? 'Notice',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              latestAlert['message'] ?? '',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFD700),
                ),
                onPressed: () async {
                  await prefs.setInt('last_seen_alert_id', latestId);
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text(
                  'DISMISS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint("Popup Error: $e");
    }
  }

  Future<void> loadHeatmapData() async {
    try {
      final data = await ApiService.getYardCapacities();
      if (!mounted) return;
      setState(() {
        yardCapacities = data;
        loadingHeatmap = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingHeatmap = false;
      });
    }
  }

  void _startCountdown(dynamic startTimeStr) {
    _countdownTimer?.cancel(); // Clear any existing clock track
    if (startTimeStr == null) return;

    DateTime? targetTime;
    try {
      targetTime = DateTime.parse(startTimeStr.toString()).toLocal();
    } catch (_) {
      return; // Stop if string format cannot parse
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = targetTime!.difference(now);

      if (difference.isNegative) {
        // Driver is inside or past their entry slot threshold
        if (mounted) {
          setState(() {
            _hoursStr = '00';
            _minutesStr = '00';
            _secondsStr = '00';
            _countdownTimer?.cancel();
          });
        }
        return;
      }

      // Convert difference duration down into block segments
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      if (mounted) {
        setState(() {
          _hoursStr = hours.toString().padLeft(2, '0');
          _minutesStr = minutes.toString().padLeft(2, '0');
          _secondsStr = seconds.toString().padLeft(2, '0');
        });
      }
    });
  }

  Widget _buildHeatmap() {
    if (loadingHeatmap) {
      return const Center(child: CircularProgressIndicator());
    }

    if (yardCapacities.isEmpty) {
      return const Center(
        child: Text(
          'System Offline: No Yard Data',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    List<dynamic> sortedYards = List.from(yardCapacities);
    sortedYards.sort((a, b) {
      final aTotal = (a['quota_total'] ?? 0) as num;
      final aReserved = (a['quota_reserved'] ?? 0) as num;
      final aRatio = aTotal == 0 ? 0.0 : aReserved / aTotal;

      final bTotal = (b['quota_total'] ?? 0) as num;
      final bReserved = (b['quota_reserved'] ?? 0) as num;
      final bRatio = bTotal == 0 ? 0.0 : bReserved / bTotal;

      return aRatio.compareTo(bRatio); // Sorts from Low (Green) -> High (Red)
    });

    // Limit to 10 visual blocks to prevent UI overflow
    final maxVisible = sortedYards.length > 10 ? 10 : sortedYards.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Clear (Low)',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Text(
              'Full (High)',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(maxVisible, (index) {
            final yard = sortedYards[index];

            final total = (yard['quota_total'] ?? 12) as num;
            final reserved = (yard['quota_reserved'] ?? 0) as num;
            final ratio = total == 0 ? 0.0 : reserved / total;

            // Traffic Color Logic
            Color color;
            if (ratio <= 0.33) {
              color = const Color(0xFF43A047);
            } else if (ratio <= 0.66) {
              color = const Color(0xFFFFB300);
            } else {
              color = const Color(0xFFE53935);
            }

            final gateName = yard['gate']?['name']?.toString() ?? 'Gate';
            final percentUsed = (ratio * 100).toStringAsFixed(0);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Tooltip(
                  message: '$gateName\n$percentUsed% Full ($reserved/$total)',
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = activeBooking;
    final slot = booking?['slot_detail'] ?? {};

    final gateName = booking == null
        ? 'No approved booking'
        : slot['gate']?['name']?.toString() ?? '';

    final containerNo = booking == null
        ? '--'
        : booking['container_number']?.toString() ?? '';

    final timeWindow = booking == null
        ? '--:-- - --:--'
        : '${_formatTime(slot['start_time'])} - ${_formatTime(slot['end_time'])}';

    final bookingRef = booking == null ? '--' : 'BK-${booking['id']}';

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            //TOB BAR
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: Color(0xFF0A2342),
              ),

              child: Row(
                children: [
                  Icon(Icons.anchor, color: Colors.white, size: 26),
                  SizedBox(width: 8),
                  Text(
                    'BandariFlow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(Icons.person, color: Color(0xFF0A2342)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            //ACTIVE BOOKING CARD
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Color(0xFF0A2342),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT SLOT STATUS',
                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            SizedBox(height: 4),
                            Text(
                              'Countdown to your active booking window',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        Transform.translate(
                          offset: Offset(0, -4),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF1D6F4E),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Color(0xFF59E38C),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  booking == null ? 'NONE' : 'LIVE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 11),
                    // LIVE SYNCHRONIZED TIMER COUNTDOWN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimeBlock(_hoursStr, 'HRS'),
                        _buildColonDivider(),
                        _buildTimeBlock(_minutesStr, 'MIN'),
                        _buildColonDivider(),
                        _buildTimeBlock(_secondsStr, 'SEC'),
                      ],
                    ),

                    SizedBox(height: 3),

                    SizedBox(height: 8),
                    Divider(color: Colors.white24, height: 1),
                    SizedBox(height: 10),

                    //MAP
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF123B73),
                                ),
                                child: Icon(
                                  Icons.access_time,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),

                              SizedBox(width: 10),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gate Window',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),

                                    SizedBox(height: 2),
                                    Text(
                                      timeWindow,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(height: 30, width: 1, color: Colors.white24),

                        SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF123B73),
                                ),
                                child: Icon(
                                  Icons.local_shipping,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),

                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Container',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      containerNo,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // YARD CAPACITY
            Container(
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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Yard Capacity Heatmap',
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Visual capacity map for port congestion',
                              style: TextStyle(
                                color: Color(0xFF0A2342),
                                fontWeight: FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildHeatmap(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        height: 6,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE53935),
                              Color(0xFFFFC107),
                              Color(0xFF43A047),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 7),

            //ACTIVE BOOKING
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0A2342),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Booking',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF1D6F4E),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10,
                                color: Color(0xFF59E38C),
                              ),
                              SizedBox(width: 6),
                              Text(
                                activeBooking == null
                                    ? 'No approved Booking'
                                    : 'Approved',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.confirmation_num_outlined,
                                color: Color(0xFF0A2342),
                              ),

                              SizedBox(width: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Container',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    containerNo,
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          SizedBox(height: 11),
                          Divider(height: 1),
                          SizedBox(height: 11),
                          Row(
                            children: [
                              Icon(
                                Icons.event_outlined,
                                color: Color(0xFF0A2342),
                              ),

                              SizedBox(width: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Appointment',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    timeWindow,
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 11),
                          Divider(height: 1),
                          SizedBox(height: 11),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF0A2342),
                              ),

                              SizedBox(width: 10),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gate',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    gateName,
                                    style: TextStyle(
                                      color: Color(0xFF0A2342),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),

                    //MAP
                    Container(
                      height: 180,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: _loadingLocation
                          ? Center(child: CircularProgressIndicator())
                          : activeBooking == null
                          ? Center(child: Text('No approved booking yet'))
                          : Builder(
                              builder: (context) {
                                final gate =
                                    activeBooking!['slot_detail']?['gate'] ??
                                    {};
                                final gateLat = (gate['latitude'] ?? 0)
                                    .toDouble();
                                final gateLng = (gate['longitude'] ?? 0)
                                    .toDouble();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GPS Ready',
                                      style: TextStyle(
                                        color: Color(0xFF0A2342),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 8),
                                    Text(
                                      'Your location: ${_currentPosition?.latitude.toStringAsFixed(5)}, ${_currentPosition?.longitude.toStringAsFixed(5)}',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    Text(
                                      'Gate location: ${gateLat.toStringAsFixed(5)}, ${gateLng.toStringAsFixed(5)}',
                                      style: TextStyle(fontSize: 17),
                                    ),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0A2342,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 2,
                                        ),
                                        onPressed: () async {
                                          final uri = Uri.parse(
                                            'https://www.google.com/maps/dir/?api=1'
                                            '&origin=${_currentPosition?.latitude},${_currentPosition?.longitude}'
                                            '&destination=$gateLat,$gateLng'
                                            '&travelmode=driving',
                                          );

                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(
                                              uri,
                                              mode: LaunchMode.platformDefault,
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Open Route',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 9),

            //BUTTON
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: activeBooking == null
                      ? null
                      : () {
                          final slot = activeBooking!['slot_detail'] ?? {};
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GatePassScreen(
                                qrToken:
                                    activeBooking!['qr_token']?.toString() ??
                                    '',
                                gateName:
                                    slot['gate']?['name']?.toString() ?? '',
                                scanText: 'Scan at Entrance',
                                status: 'Verified',
                                containerNumber:
                                    activeBooking!['container_number']
                                        ?.toString() ??
                                    '',
                                timeWindow:
                                    '${_formatTime(slot['start_time'])} - ${_formatTime(slot['end_time'])}',
                                bookingRef: 'BK-${activeBooking!['id']}',
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFD700),
                    foregroundColor: Color(0xFF0A2342),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2, color: Colors.black54, size: 30),
                      SizedBox(width: 9),
                      Text(
                        'VIEW GATE PASS',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      //BOTTOM NAVIGATION BAR
      bottomNavigationBar: const DriverBottomNav(currentIndex: 0),
    );
  }

  Widget _buildTimeBlock(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildColonDivider() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: 20,
      ), // FIXED: Changed to only() so bottom is allowed
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white38,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ignore: unused_element
Widget _statusDot(String label, Color color) {
  return Padding(
    padding: EdgeInsets.only(right: 12),
    child: Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        SizedBox(width: 6),
        Text(label),
      ],
    ),
  );
}

class _HeatBox extends StatelessWidget {
  final Color color;

  const _HeatBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
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
