import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/driver/update_profile.dart';
import 'package:bandariflow/views/admin/widgets/admin_bottom_nav.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  Map<String, dynamic>? profile;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      loading = true;
      error = null;
    });
    try {
      print("STARTING PROFILE API CALL...");
      final data = await ApiService.getDriverProfile();
      print("PROFILE API FETCH SUCCESS: $data");

      if (!mounted) return;
      setState(() {
        profile = data;
        loading = false;
      });
    } catch (e) {
      print("CRITICAL NETWORK ERROR DETECTED: $e");
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //TOP BAR
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(color: Color(0xFF0A2342)),

                child: Row(
                  children: [
                    Icon(Icons.anchor, color: Colors.white, size: 30),

                    Expanded(
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),

              // Replace the entire profile image SizedBox block in your profile_page.dart:
              SizedBox(
                width: 120,
                height: 120,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: const Color(0xFF0A2342),
                  backgroundImage: profile?['photo'] != null
                      ? NetworkImage(
                          profile!['photo'].toString().startsWith('http')
                              ? profile!['photo']
                              : 'http://10.0.2.2:8000${profile!['photo']}',
                        )
                      : null,
                  child: profile?['photo'] == null
                      ? Text(
                          // ✅ Fixed: Safely checks if name is blank or null before slicing string memory channels
                          (profile?['fullname'] != null &&
                                  profile!['fullname']
                                      .toString()
                                      .trim()
                                      .isNotEmpty)
                              ? profile!['fullname']
                                    .toString()
                                    .trim()
                                    .substring(0, 1)
                                    .toUpperCase()
                              : 'D', // Fallback to 'D' for Driver if the field is empty string ""
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),

              SizedBox(height: 10),
              Text(
                profile?['fullname'] ?? 'Driver Name',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
              Text(
                profile?['user_email'] ?? '',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                profile?['preferred_truck'] ?? 'No truck assigned',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (profile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile data is still loading...'),
                      ),
                    );
                    return;
                  }
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          UpdateProfilePage(profile: profile!),
                    ),
                  );
                  if (updated == true) {
                    loadProfile();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 12, 44, 83),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text('Edit Profile'),
              ),

              SizedBox(height: 10),
              Padding(padding: const EdgeInsets.all(8.0), child: Divider()),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                  children: [
                    _profileItem(
                      icon: Icons.phone_android_outlined,
                      title: 'Phone',
                      value: profile?['phone'] ?? '',
                    ),

                    SizedBox(height: 10),
                    Divider(height: 1),
                    SizedBox(height: 10),

                    _profileItem(
                      icon: Icons.mail_outline,
                      title: 'Email',
                      value: profile?['user_email'] ?? '',
                    ),

                    SizedBox(height: 10),
                    Divider(height: 1),
                    SizedBox(height: 10),

                    _profileItem(
                      icon: Icons.local_shipping_outlined,
                      title: 'Truck',
                      value: profile?['preferred_truck']?.toString() ?? '',
                    ),

                    SizedBox(height: 10),
                    Divider(height: 1),
                    SizedBox(height: 10),

                    Container(
                      width: double.infinity,
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
                          const Text(
                            'Account',
                            style: TextStyle(
                              color: Color(0xFF0A2342),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),

                          InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Logout'),
                                    content: const Text(
                                      'Are you sure you want to log out?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);

                                          Navigator.pushReplacementNamed(
                                            context,
                                            '/login',
                                          );
                                        },
                                        child: const Text(
                                          'Logout',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5F5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFFFD6D6),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.logout_outlined,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Log out',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(Icons.chevron_right, color: Colors.red),
                                ],
                              ),
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
        ),
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 3),
    );
  }
}

Widget _profileItem({
  required IconData icon,
  required String title,
  required String value,
}) {
  return Row(
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Color(0xFFEAF1FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Color(0xFF0A2342), size: 22),
      ),

      SizedBox(width: 12),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.black54, fontSize: 12)),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: Color(0xFF0A2342),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
