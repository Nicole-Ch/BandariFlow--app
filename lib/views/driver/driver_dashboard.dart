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
  Map<String, dynamic>? driverProfile;

  Timer? _countdownTimer;
  String _hoursStr = '00';
  String _minutesStr = '00';
  String _secondsStr = '00';
  Position? _currentPosition;
  bool _loadingLocation = true;
  List<dynamic> yardCapacities = [];
  bool loadingHeatmap = true;
  bool _isInitialLoaded = false;
  bool _isFetching = false;

  @override
  void dispose() {
    _countdownTimer
        ?.cancel(); // Stops timer running in background when page closes
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    debugPrint("INIT STATE -> ${identityHashCode(this)}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialLoaded) {
        _runUnifiedFetchPipeline();
      }
    });
  }

  Future<void> _runUnifiedFetchPipeline() async {
    debugPrint(
      "PIPELINE ${identityHashCode(this)} "
      "fetch=$_isFetching loaded=$_isInitialLoaded",
    );
    if (_isFetching || _isInitialLoaded) return;

    setState(() {
      _isFetching = true;
    });

    try {
      debugPrint(
        "=== STARTING UNIFIED DATA RECONCILIATION FOR BANDARIFLOW ===",
      );

      // Run profile and booking requests concurrently on the background pool
      final results = await Future.wait([
        ApiService.getDriverProfile(),
        ApiService.getBookings(),
      ]);

      final profileData = results[0] as Map<String, dynamic>?;
      final bookingsData = results[1] as List<dynamic>;

      Map<String, dynamic>? approvedBooking;
      Map<String, dynamic>? latestBooking;

      if (bookingsData.isNotEmpty) {
        latestBooking = Map<String, dynamic>.from(bookingsData.first);
      }

      // Isolate active approved container reservations
      for (final booking in bookingsData) {
        final status = booking['status']?.toString().toLowerCase() ?? '';
        if (status == 'approved') {
          approvedBooking = Map<String, dynamic>.from(booking);
          break;
        }
      }

      if (!mounted) return;
      setState(() {
        driverProfile = profileData;
        bookings = bookingsData;
        activeBooking = approvedBooking;
        loading = false;
        _isInitialLoaded = true;
      });

      // Initialize slot expiration clocks
      if (approvedBooking != null) {
        _startCountdown(approvedBooking['slot_detail']?['start_time']);
      }

      await loadHeatmapData();

      // Check for broadcast informational notes safely
      await checkForBroadcastAlerts();

      // Check physical geofenced coordinates
      await _loadCurrentLocation();

      debugPrint(
        "=== UNIFIED DATA ENGINE COMPLETED PROCESSING SLOTS BACKEND ===",
      );
    } catch (e) {
      debugPrint("Pipeline Fatal Execution Error: $e");
      if (mounted) {
        setState(() {
          bookings = [];
          activeBooking = null;
          yardCapacities = [];
          loading = false;
          loadingHeatmap = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false; // Release network concurrency guard lock cleanly
        });
      }
    }
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

      final position = Position(
        latitude: -1.2921,
        longitude: 36.8219,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 1795.0,
        altitudeAccuracy: 1.0,
        heading: 0.0,
        headingAccuracy: 1.0,
        speed: 0.0,
        speedAccuracy: 1.0,
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

  Future<void> loadHeatmapData({int? gateId}) async {
    try {
      final data = await ApiService.getYardCapacities();

      if (!mounted) return;

      setState(() {
        yardCapacities = data;
        loadingHeatmap = false;
      });
    } catch (e) {
      debugPrint("Heatmap Error: $e");

      if (!mounted) return;

      setState(() {
        yardCapacities = [];
        loadingHeatmap = false;
      });
    }
  }

  Widget _buildHeatmap() {
    if (loadingHeatmap) {
      return const Center(child: CircularProgressIndicator());
    }

    if (yardCapacities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'System Offline: No Yard Data Available',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final Map<String, List<double>> gateRatios = {};

    for (var yard in yardCapacities) {
      final String gateName =
          yard['gate']?['name']?.toString() ?? 'Terminal Gate';
      final total = (yard['quota_total'] ?? 1) as num;
      final reserved = (yard['quota_reserved'] ?? 0) as num;
      final ratio = total == 0 ? 0.0 : reserved / total;

      if (!gateRatios.containsKey(gateName)) {
        gateRatios[gateName] = [];
      }
      gateRatios[gateName]!.add(ratio.toDouble());
    }

    // Convert the grouped map back into a clean list for the UI
    final List<Map<String, dynamic>> uniqueGatesList = [];
    gateRatios.forEach((gateName, ratiosList) {
      // Calculate the mathematical average ratio for this specific gate
      final double avgRatio =
          ratiosList.reduce((a, b) => a + b) / ratiosList.length;
      uniqueGatesList.add({
        'name': gateName,
        'ratio': avgRatio,
        'percentage': (avgRatio * 100).round(),
      });
    });

    uniqueGatesList.sort(
      (a, b) => (a['ratio'] as double).compareTo(b['ratio'] as double),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 12),

        Column(
          children: List.generate(uniqueGatesList.length, (index) {
            final gate = uniqueGatesList[index];
            final String name = gate['name'];
            final int percent = gate['percentage'];
            final double ratio = gate['ratio'];

            // Clean traffic light indicator color logic based on utilization bounds
            Color lightColor;
            if (ratio <= 0.33) {
              lightColor = const Color(0xFF43A047); // Green
            } else if (ratio <= 0.66) {
              lightColor = const Color(0xFFFFB300); // Yellow
            } else {
              lightColor = const Color(0xFFE53935); // Red
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: lightColor,
                      boxShadow: [
                        BoxShadow(
                          color: lightColor.withAlpha(80),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // GATE NAME LABEL
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),

                  // PERCENTAGE FULL CAPACITY VALUE
                  Text(
                    "$percent% full",
                    style: const TextStyle(
                      // Added const here for better build performance!
                      fontSize: 16,
                      fontWeight: FontWeight
                          .bold, // Swapped from ultra-heavy w900 to bold for a cleaner look
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  void _startCountdown(dynamic startTimeStr) {
    _countdownTimer?.cancel();
    if (startTimeStr == null) return;

    DateTime? targetTime;
    try {
      targetTime = DateTime.parse(startTimeStr.toString()).toLocal();
    } catch (_) {
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = targetTime!.difference(now);

      if (difference.isNegative) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _hoursStr = '00';
            _minutesStr = '00';
            _secondsStr = '00';
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _hoursStr = difference.inHours.toString().padLeft(2, '0');
          _minutesStr = (difference.inMinutes.remainder(
            60,
          )).toString().padLeft(2, '0');
          _secondsStr = (difference.inSeconds.remainder(
            60,
          )).toString().padLeft(2, '0');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
      backgroundColor: Color(0xFFF5F7FB),

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
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: driverProfile?['photo'] != null
                        ? NetworkImage(
                            driverProfile!['photo'].toString().startsWith(
                                  'http',
                                )
                                ? driverProfile!['photo']
                                : 'http://10.0.2.2:8000${driverProfile!['photo']}',
                          )
                        : null,
                    child: driverProfile?['photo'] == null
                        ? Text(
                            (driverProfile?['fullname'] != null &&
                                    driverProfile!['fullname']
                                        .toString()
                                        .trim()
                                        .isNotEmpty)
                                ? driverProfile!['fullname']
                                      .toString()
                                      .trim()
                                      .substring(0, 1)
                                      .toUpperCase()
                                : 'D',
                            style: const TextStyle(
                              color: Color(0xFF0A2342),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
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

String _formatTime(dynamic value) {
  if (value == null) return '--:--';
  final text = value.toString();
  if (text.length >= 16) {
    return text.substring(11, 16);
  }
  return text;
}
