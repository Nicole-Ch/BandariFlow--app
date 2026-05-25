import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api'; // Edge / Chrome / Flutter web
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api'; // Android emulator
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8000/api'; // iOS simulator
      default:
        return 'http://127.0.0.1:8000/api'; // Windows/macOS/Linux
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> createBooking({
    required int slotId,
    required int truckId,
    required int shippingLineId,
    required String containerNumber,
    required bool isEmpty,
    required String direction,
    required String manifestNumber,
    required int yardCapacityId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bookings/create/'),
      headers: await authHeaders(),
      body: jsonEncode({
        'slot': slotId,
        'truck': truckId,
        'shippingline': shippingLineId,
        'container_number': containerNumber,
        'is_empty': isEmpty,
        'direction': direction,
        'manifest_number': manifestNumber,
        'yard_capacity': yardCapacityId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to create booking: ${response.body}');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access']);
      return data;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Register failed: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> getDriverProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/driver/profile'),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to load driver profile : ${response.body}');
  }

  static Future<Map<String, dynamic>> updateDriverProfile({
    required String fullName,
    required String phone,
    required String idNumber,
    required String licenseNumber,
    required String truckPlate,
    File? imageFile, // This accepts the image file from your image picker
  }) async {
    // Create a PATCH multipart request
    final url = Uri.parse('$baseUrl/driver/profile/');
    final request = http.MultipartRequest('PATCH', url);

    // Fetch and apply your authentication headers
    final headers = await authHeaders();

    headers.remove('Content-Type');
    request.headers.addAll(headers);

    //  Attach text form fields
    request.fields['fullname'] = fullName;
    request.fields['phone'] = phone;
    request.fields['id_number'] = idNumber;
    request.fields['license_number'] = licenseNumber;
    request.fields['preferred_truck'] = truckPlate;

    // Attach the image file if it is selected
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo', // This key name MUST exactly match your Django model/serializer field name
          imageFile.path,
        ),
      );
    }

    // Send the streaming request to  Django API
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    //  Handle the server response status
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to update driver profile: ${response.body}');
  }

  static Future<List<dynamic>> getSlots({int? gateId}) async {
    final uri = gateId == null
        ? Uri.parse('$baseUrl/slots/')
        : Uri.parse('$baseUrl/slots/?gate_id=$gateId');

    final response = await http.get(uri, headers: await authHeaders());

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load slots: ${response.body}');
  }

  static Future<List<dynamic>> getTrucks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/trucks/'),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load trucks');
  }

  static Future<List<dynamic>> getShippingLines() async {
    final response = await http.get(
      Uri.parse('$baseUrl/shippingline/'),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load shipping lines');
  }

  static Future<Map<String, dynamic>> createBookings({
    required int slotId,
    required int truckId,
    required int shippingLineId,
    required String containerNumber,
    required bool isEmpty,
    required String direction,
    required String manifestNumber,
    int? yardCapacityId,
  }) async {
    final body = <String, dynamic>{
      'slot': slotId,
      'truck': truckId,
      'shippingline': shippingLineId,
      'container_number': containerNumber,
      'is_empty': isEmpty,
      'direction': direction,
      'manifest_number': manifestNumber,
    };

    if (yardCapacityId != null) {
      body['yard_capacity'] = yardCapacityId;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/bookings/create/'),
      headers: await authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception('Failed to create booking: ${response.body}');
  }

  static Future<void> uploadBookingDocument({
    required int bookingId,
    required File file,
  }) async {
    final uri = Uri.parse('$baseUrl/bookings/documents/create/');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await authHeaders())
      ..fields['booking'] = bookingId.toString()
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception('Failed to upload: ${response.body}');
    }
  }

  static Future<List<dynamic>> getBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bookings/'),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load bookings: ${response.body}');
  }

  static Future<List<dynamic>> getGates() async {
    final response = await http.get(
      Uri.parse('$baseUrl/gates/'),
      headers: await authHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load gates: ${response.body}');
  }

  static Future<List<dynamic>> getBroadcastAlerts() async {
    try {
      final headers = await authHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/broadcasts/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      throw Exception('Failed to load broadcasts: ${response.body}');
    } catch (e) {
      debugPrint('Broadcast Networking Sync Error: $e');
      return [];
    }
  }
}
