import 'package:bandariflow/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  final TextEditingController _manualTokenController = TextEditingController();

  bool _isProcessing = false;
  String _statusText = 'Point the camera at a QR code';
  Color _statusColor = const Color(0xFF0A2342);

  @override
  void dispose() {
    _controller.dispose();
    _manualTokenController.dispose();
    super.dispose();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _submitToken(String token) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusText = 'Verifying gate pass...';
      _statusColor = const Color(0xFF0A2342);
    });

    try {
      print("========== STEP 1 ==========");
      print("Submit button pressed");
      print("QR Token:");
      print(token);

      final position = await _getCurrentPosition();

      print("========== STEP 2 ==========");
      print("GPS finished");

      if (position != null) {
        print("Latitude: ${position.latitude}");
        print("Longitude: ${position.longitude}");
      } else {
        print("GPS returned NULL");
      }

      print("========== STEP 3 ==========");
      print("Calling ApiService.scanGatePass()");

      final response = await ApiService.scanGatePass(
        qrToken: token,
        scannerLat: position?.latitude,
        scannerLon: position?.longitude,
        deviceInfo: 'Android Scanner',
      );

      print("========== STEP 4 ==========");
      print("API call completed successfully");
      print(response);

      if (!mounted) return;

      setState(() {
        _statusText = response['detail']?.toString() ?? 'Scan successful';
        _statusColor = Colors.green;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusText), backgroundColor: Colors.green),
      );
    } catch (e, stackTrace) {
      print("========== ERROR ==========");
      print(e);
      print(stackTrace);

      if (!mounted) return;

      setState(() {
        _statusText = 'Scan failed';
        _statusColor = Colors.red;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      print("========== FINISHED ==========");

      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _Logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you really want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),

        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A2342), Color(0xFF123B73)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'QR Gate Validation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: _Logout,
                        tooltip: 'Logout',
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusColor == Colors.green
                          ? const Color(0xFF9EF0B2)
                          : Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: MobileScanner(
                          controller: _controller,
                          onDetect: (capture) {
                            if (_isProcessing) return;
                            final barcodes = capture.barcodes;
                            if (barcodes.isEmpty) return;

                            final token = barcodes.first.rawValue;
                            if (token == null || token.isEmpty) return;

                            _submitToken(token);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
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
                          const Text(
                            'Manual test mode',
                            style: TextStyle(
                              color: Color(0xFF0A2342),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Paste the scanned token here when testing on emulator.',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _manualTokenController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Paste QR token here',
                              filled: true,
                              fillColor: const Color(0xFFF7F9FC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () {
                                      final token = _manualTokenController.text
                                          .trim();
                                      if (token.isEmpty) return;
                                      _submitToken(token);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0A2342),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Verify Gate Pass',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
