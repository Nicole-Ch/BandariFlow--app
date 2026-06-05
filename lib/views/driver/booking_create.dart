import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/driver/driver_dashboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bandariflow/views/driver/widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:bandariflow/views/driver/tickets_page.dart';

class BookingCreate extends StatefulWidget {
  const BookingCreate({super.key});

  @override
  State<BookingCreate> createState() => _BookingCreateState();
}

class _BookingCreateState extends State<BookingCreate> {
  final containerNumberController = TextEditingController();
  final manifestNumberController = TextEditingController();
  int? createdBookingId;
  List<dynamic> slots = [];
  List<dynamic> trucks = [];
  List<dynamic> shippingLines = [];
  List<dynamic> gates = [];

  int? selectedGateId;

  bool loadingGates = true;
  bool loadingSlots = false;

  int? selectedSlotId;
  int? selectedTruckId;
  int? selectedShippingLineId;

  bool isEmpty = false;
  String direction = 'import_pickup';

  bool loading = true;
  String? error;

  bool bookingCreated = false;
  bool documentUploaded = false;

  @override
  void initState() {
    super.initState();
    loadGates();
    loadData();
  }

  Future<void> loadGates() async {
    try {
      final data = await ApiService.getGates();
      setState(() {
        gates = data;
        loadingGates = false;
      });
    } catch (e) {
      setState(() {
        loadingGates = false;
      });
    }
  }

  Future<void> loadSlotsForGate(int gateId) async {
    try {
      setState(() {
        loadingSlots = true;
        slots = [];
        selectedSlotId = null;
      });

      final data = await ApiService.getSlots(gateId: gateId);

      setState(() {
        slots = data;
        loadingSlots = false;
      });
    } catch (e) {
      setState(() {
        loadingSlots = false;
      });
    }
  }

  @override
  void dispose() {
    containerNumberController.dispose();
    manifestNumberController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final results = await Future.wait([
        ApiService.getTrucks(),
        ApiService.getShippingLines(),
      ]);

      List<dynamic> sortedLines = List.from(results[1]);
      sortedLines.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

      if (!mounted) return;
      setState(() {
        trucks = results[0];
        shippingLines = sortedLines;
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

  Future<bool> requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> submitBooking() async {
    if (bookingCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking already created. Upload the document to continue.',
          ),
        ),
      );
      return;
    }

    if (selectedSlotId == null ||
        selectedTruckId == null ||
        selectedShippingLineId == null ||
        containerNumberController.text.trim().isEmpty ||
        manifestNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final result = await ApiService.createBookings(
        slotId: selectedSlotId!,
        truckId: selectedTruckId!,
        shippingLineId: selectedShippingLineId!,
        containerNumber: containerNumberController.text.trim(),
        isEmpty: isEmpty,
        direction: direction,
        manifestNumber: manifestNumberController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        createdBookingId = result['id'];
        bookingCreated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking created successfully. Upload supporting documents to complete submission.',
          ),
        ),
      );

      debugPrint('Booking created: $result');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String formatDate(dynamic value) {
    if (value == null) return '--';
    final text = value.toString();
    if (text.length < 10) return text;
    return text.substring(0, 10);
  }

  String formatTime(dynamic value) {
    if (value == null) return '--';
    final text = value.toString();
    if (text.length < 16) return text.substring(11, 16);
    return text;
  }

  void _showAddTruckDialog() {
    final plateController = TextEditingController();
    bool isCertified = false;
    String? selectedFileName;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: const [
                Icon(Icons.shield, color: Color(0xFF0A2342)),
                SizedBox(width: 8),
                Text(
                  'Verify Company Truck',
                  style: TextStyle(
                    color: Color(0xFF0A2342),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To prevent unauthorized bookings, please provide your vehicle details and registration logbook.',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: plateController,
                    enabled: !isUploading,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Truck Plate Number',
                      hintText: 'e.g., KCD 456X',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_shipping),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: isUploading
                        ? null
                        : () async {
                            setDialogState(() => isUploading = true);

                            await Future.delayed(
                              const Duration(milliseconds: 800),
                            );

                            setDialogState(() {
                              selectedFileName =
                                  "logbook_copy_${plateController.text.trim().replaceAll(' ', '_')}.pdf";
                              isUploading = false;
                            });
                          },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.withValues(alpha: 0.05),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedFileName != null
                                ? Icons.picture_as_pdf
                                : Icons.upload_file,
                            color: selectedFileName != null
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedFileName ?? 'Upload Truck Logbook (PDF)',
                              style: TextStyle(
                                color: selectedFileName != null
                                    ? Colors.black
                                    : Colors.grey[700],
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text(
                      "I certify that this truck is officially leased or owned by my registered company transport fleet.",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    value: isCertified,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: const Color(0xFF0A2342),
                    onChanged: isUploading
                        ? null
                        : (bool? value) {
                            setDialogState(() {
                              isCertified = value ?? false;
                            });
                          },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color.fromARGB(255, 134, 133, 133)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2342),
                  foregroundColor: Colors.white,
                ),
                onPressed:
                    (!isCertified ||
                        selectedFileName == null ||
                        plateController.text.trim().isEmpty ||
                        isUploading)
                    ? null
                    : () async {
                        setDialogState(() => isUploading = true);

                        try {
                          final plate = plateController.text
                              .trim()
                              .toUpperCase();

                          await ApiService.updateDriverProfile(
                            truckPlate: plate,
                          );

                          final updatedTrucks = await ApiService.getTrucks();

                          if (!mounted) return;
                          setState(() {
                            trucks = updatedTrucks;
                            selectedTruckId = updatedTrucks.isNotEmpty
                                ? updatedTrucks.first['id']
                                : null;
                          });

                          if (!mounted) return;
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Truck linked successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Truck link failed: $e')),
                          );
                        } finally {
                          if (mounted) {
                            setDialogState(() => isUploading = false);
                          }
                        }
                      },
                child: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Verify & Submit'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _uploadBookingDocumentAndGoHome() async {
    if (createdBookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please submit the booking first, then upload documents.',
          ),
        ),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Uploading document...')));

    try {
      await ApiService.uploadBookingDocument(
        bookingId: createdBookingId!,
        file: File(result.files.single.path!),
      );

      if (!mounted) return;
      setState(() {
        documentUploaded = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully!')),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyTicketsPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Create Booking'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A2342),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DriverDashboard()),
            );
          },
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFD),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE1E7F0)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                'assets/images/Truck.jpg',
                                width: 120,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 47,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (!bookingCreated) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Please submit the booking first before uploading documents.',
                                          ),
                                          backgroundColor: const Color(
                                            0xFF1E1E1E,
                                          ).withAlpha(230), // 90% opacity
                                          // Material Grey 900
                                        ),
                                      );
                                      return;
                                    }

                                    _uploadBookingDocumentAndGoHome();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2F6FD6),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_file_outlined,
                                        size: 22,
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          'Upload Docs',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
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
                      const SizedBox(height: 18),
                      const Divider(height: 1),
                      const SizedBox(height: 18),
                      _fieldCard(
                        icon: Icons.confirmation_num_outlined,
                        title: 'Container Number',
                        child: TextField(
                          controller: containerNumberController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter container number',
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _fieldCard(
                        icon: Icons.apartment,
                        title: 'Gate',
                        child: loadingGates
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(),
                              )
                            : DropdownButtonFormField<int>(
                                value: selectedGateId,
                                decoration: _inputDecoration(),
                                isExpanded: true,
                                items: gates.map((gate) {
                                  return DropdownMenuItem<int>(
                                    value: gate['id'],
                                    child: Text(gate['name'].toString()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGateId = value;
                                  });

                                  if (value != null) {
                                    loadSlotsForGate(value);
                                  }
                                },
                              ),
                      ),
                      _fieldCard(
                        icon: Icons.calendar_month,
                        title: 'Slot',
                        child: loadingSlots
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: CircularProgressIndicator(),
                              )
                            : DropdownButtonFormField<int>(
                                value: selectedSlotId,
                                decoration: _inputDecoration(),
                                isExpanded: true,
                                items: slots.map((slot) {
                                  final gate = slot['gate']?['name'] ?? 'Gate';
                                  final date = formatDate(slot['start_time']);
                                  final start = formatTime(slot['start_time']);
                                  final end = formatTime(slot['end_time']);

                                  return DropdownMenuItem<int>(
                                    value: slot['id'],
                                    child: Text(
                                      '$gate | $date | $start - $end',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => selectedSlotId = value);
                                },
                              ),
                      ),
                      const SizedBox(height: 14),
                      _fieldCard(
                        icon: Icons.local_shipping_rounded,
                        title: 'Truck',
                        child: trucks.isEmpty
                            ? InkWell(
                                onTap: _showAddTruckDialog,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.orange.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.orange.withValues(
                                      alpha: 0.05,
                                    ),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'No trucks found. Tap here to register & link truck.',
                                          style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : DropdownButtonFormField<int>(
                                value: selectedTruckId,
                                decoration: _inputDecoration(),
                                items: trucks.map((truck) {
                                  return DropdownMenuItem<int>(
                                    value: truck['id'],
                                    child: Text(
                                      truck['license_plate'] ?? 'Truck',
                                    ),
                                  );
                                }).toList(),
                                onChanged: bookingCreated
                                    ? null
                                    : (value) {
                                        setState(() => selectedTruckId = value);
                                      },
                              ),
                      ),
                      const SizedBox(height: 14),
                      _fieldCard(
                        icon: Icons.apartment,
                        title: 'Shipping Line',
                        child: DropdownButtonFormField<int>(
                          value: selectedShippingLineId,
                          decoration: _inputDecoration(),
                          items: shippingLines.map((line) {
                            return DropdownMenuItem<int>(
                              value: line['id'],
                              child: Text(line['name'] ?? 'Shipping Line'),
                            );
                          }).toList(),
                          onChanged: bookingCreated
                              ? null
                              : (value) {
                                  setState(
                                    () => selectedShippingLineId = value,
                                  );
                                },
                        ),
                      ),
                      const SizedBox(height: 14),
                      _fieldCard(
                        icon: Icons.scale,
                        title: 'Container Status',
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            isEmpty ? 'Empty Container' : 'Full Container',
                          ),
                          value: isEmpty,
                          onChanged: bookingCreated
                              ? null
                              : (value) {
                                  setState(() => isEmpty = value);
                                },
                        ),
                      ),
                      const SizedBox(height: 14),
                      _fieldCard(
                        icon: Icons.swap_horiz,
                        title: 'Direction',
                        child: DropdownButtonFormField<String>(
                          value: direction,
                          decoration: _inputDecoration(),
                          items: const [
                            DropdownMenuItem(
                              value: 'import_pickup',
                              child: Text('Import Pickup'),
                            ),
                            DropdownMenuItem(
                              value: 'export_dropoff',
                              child: Text('Export Drop-Off'),
                            ),
                            DropdownMenuItem(
                              value: 'empty_return',
                              child: Text('Empty Return'),
                            ),
                          ],
                          onChanged: bookingCreated
                              ? null
                              : (value) {
                                  if (value != null) {
                                    setState(() => direction = value);
                                  }
                                },
                        ),
                      ),
                      const SizedBox(height: 14),
                      _fieldCard(
                        icon: Icons.notes_rounded,
                        title: 'Manifest Number',
                        child: TextField(
                          controller: manifestNumberController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter manifest number',
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      SizedBox(
                        width: double.infinity,
                        height: 49,
                        child: ElevatedButton(
                          onPressed: bookingCreated ? null : submitBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F6FD6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            bookingCreated
                                ? 'Booking Submitted'
                                : 'Submit Booking',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      if (bookingCreated) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Booking created. Upload the document above to finish and return to the dashboard.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const DriverBottomNav(currentIndex: 1),
    );
  }

  Widget _fieldCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E7F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2F6FD6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0A2342),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      border: InputBorder.none,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
