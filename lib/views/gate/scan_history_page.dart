import 'package:flutter/material.dart';
import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/gate/driver_details.dart';

class ScanHistoryPage extends StatefulWidget {
  final VoidCallback? onBackToScan;
  const ScanHistoryPage({super.key, this.onBackToScan});

  @override
  State<ScanHistoryPage> createState() => _ScanHistoryPageState();
}

class _ScanHistoryPageState extends State<ScanHistoryPage> {
  List<dynamic> _logs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final logs = await ApiService.getGateScanLogs();
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
    return null;
  }

  String _text(dynamic value, [String fallback = '--']) {
    if (value == null) return fallback;
    final s = value.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  String _formatDateTime(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return '--';
    try {
      final dt = DateTime.parse(text).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year  $hour:$minute';
    } catch (_) {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBackToScan != null) {
              widget.onBackToScan!(); // Switch to Scan tab (gate staff)
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context); // Normal back (admin dashboard)
            } else {
              // Fallback: go to admin dashboard
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/adminDashboard',
                (route) => false,
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _fetchLogs,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [Expanded(child: _buildBody())]),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 54, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchLogs,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_logs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchLogs,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Icon(Icons.history, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'No scans have been recorded yet.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchLogs,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          final scan = _asMap(_logs[index]) ?? {};
          return _buildScanCard(scan);
        },
      ),
    );
  }

  Widget _buildScanCard(Map<String, dynamic> scan) {
    final bookingDetail = _asMap(scan['booking_detail']) ?? {};
    final driver = _asMap(bookingDetail['driver']) ?? {};
    final slotDetail = _asMap(bookingDetail['slot_detail']) ?? {};
    final gate = _asMap(slotDetail['gate']) ?? {};

    final bool valid = scan['valid'] == true;
    final String reason = _text(scan['reason']);
    final String scannedAt = _formatDateTime(scan['scanned_at']);
    final String bookingId = _text(bookingDetail['id'], '??');
    final String driverName = _text(driver['fullname'], 'Unknown Driver');
    final String containerNumber = _text(bookingDetail['container_number']);
    final String gateName = _text(gate['name'], 'Unknown Gate');

    final officerRaw = scan['scanner_officer'];
    final String officer = officerRaw == null
        ? 'N/A'
        : officerRaw is Map<String, dynamic>
        ? (officerRaw['username']?.toString() ?? 'N/A')
        : officerRaw.toString();

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        final scanData = <String, dynamic>{'booking': bookingDetail};
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DriverLogs(scanData: scanData)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: valid
                        ? const Color(0xFFE8F7ED)
                        : const Color(0xFFFDECEC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    valid ? Icons.check_circle : Icons.cancel,
                    color: valid
                        ? const Color(0xFF1B8F3A)
                        : const Color(0xFFB42318),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking #$bookingId',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0A2342),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scannedAt,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: valid
                        ? const Color(0xFFE8F7ED)
                        : const Color(0xFFFDECEC),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    valid ? 'VALID' : 'INVALID',
                    style: TextStyle(
                      color: valid
                          ? const Color(0xFF1B8F3A)
                          : const Color(0xFFB42318),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _detailRow(Icons.person, 'Driver', driverName),
            _detailRow(Icons.local_shipping, 'Container', containerNumber),
            _detailRow(Icons.location_on, 'Gate', gateName),
            _detailRow(Icons.security, 'Officer', officer),
            if (reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: $reason',
                style: TextStyle(
                  color: valid ? Colors.black54 : const Color(0xFFB42318),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0A2342)),
          const SizedBox(width: 8),
          SizedBox(
            width: 82,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
