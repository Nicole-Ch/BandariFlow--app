import 'package:bandariflow/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const UpdateProfilePage({super.key, required this.profile});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController truckController;
  late final TextEditingController passwordController;
  late final TextEditingController idNumberController;
  late final TextEditingController licenseController;

  bool obscurePassword = true;
  bool isSaving = false;
  Uint8List?
  profileImageBytes; // holds the raw binary data (the actual bytes) of the image file
  String? pickedFileName;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(
      text: widget.profile['fullname'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.profile['phone'] ?? '',
    );
    idNumberController = TextEditingController(
      text: widget.profile['id_number'] ?? '',
    );
    emailController = TextEditingController(
      text: widget.profile['user_email'] ?? '',
    );
    truckController = TextEditingController(
      text: widget.profile['preferred_truck'] ?? '',
    );
    passwordController = TextEditingController(text: '');

    licenseController = TextEditingController(
      text: widget.profile['license_number'] ?? '',
    );
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    truckController.dispose();
    passwordController.dispose();
    idNumberController.dispose();
    licenseController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);
    try {
      File? imageFile;
      if (profileImageBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final name = pickedFileName ?? "profile_temp.jpg";
        imageFile = File('${tempDir.path}/$name');
        await imageFile.writeAsBytes(profileImageBytes!);
      }
      print("========== SAVE PROFILE ==========");
      print("Image bytes null? ${profileImageBytes == null}");
      print("Picked filename: $pickedFileName");
      print("Image file path: ${imageFile?.path}");
      print("Image exists: ${imageFile?.existsSync()}");
      print("Image size: ${imageFile?.lengthSync()}");

      await ApiService.updateDriverProfile(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        idNumber: idNumberController.text.trim(),
        licenseNumber: licenseController.text.trim(),
        truckPlate: truckController.text.trim(),
        imageFile: imageFile,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      // Check if the error is due to an expired token session
      if (e.toString().contains('token_not_valid') ||
          e.toString().contains('expired')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your session has expired. Please log in again.'),
          ),
        );

        // Clear the invalid token immediately so the app can recover
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');

        if (!mounted) return;
        // Kick the user out safely to the login portal screen
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      } else {
        // Normal network or validation error handling fallback
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Update Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> pickProfileImage() async {
    print("Opening picker...");

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    print("Picker closed");

    if (result != null) {
      print("Image selected");

      setState(() {
        profileImageBytes = result.files.single.bytes;
        pickedFileName = result.files.single.name;
      });

      print("Bytes length: ${profileImageBytes?.length}");
      print("Filename: $pickedFileName");
    } else {
      print("User cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String initialLetter = (fullNameController.text.trim().isNotEmpty)
        ? fullNameController.text.trim().substring(0, 1).toUpperCase()
        : (widget.profile['fullname'] != null &&
              widget.profile['fullname'].toString().trim().isNotEmpty)
        ? widget.profile['fullname']
              .toString()
              .trim()
              .substring(0, 1)
              .toUpperCase()
        : 'D';
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 5),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFBFD6F6), width: 3),
                    ),
                    child: ClipOval(
                      child: profileImageBytes != null
                          ? Image.memory(
                              profileImageBytes!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            )
                          : widget.profile['photo'] != null
                          ? Image.network(
                              widget.profile['photo'].toString().startsWith(
                                    'http',
                                  )
                                  ? widget.profile['photo']
                                  : 'http://10.0.2.2:8000${widget.profile['photo']}',
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: const Color(0xFF0A2342),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initialLetter,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                            )
                          : Container(
                              // FIXED: Show dynamic clean color profile circle with initials text instead of assets
                              color: const Color(0xFF0A2342),
                              alignment: Alignment.center,
                              child: Text(
                                initialLetter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 44,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),

                  GestureDetector(
                    onTap: pickProfileImage,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF2F6FD6),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),

              Text(
                'Edit',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 18),

              // UPDATE FIELDS
              Container(
                padding: EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE1E7F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        color: Color(0xFF0A2342),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'FullName',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 7),
                          TextField(
                            controller: fullNameController,
                            style: TextStyle(color: Color(0xFF0A2342)),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFE1E7F0),
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

              SizedBox(height: 15),

              Container(
                padding: EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE1E7F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.badge,
                        color: Color(0xFF0A2342),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'National ID Number',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 7),
                          TextField(
                            controller: idNumberController,
                            style: TextStyle(color: Color(0xFF0A2342)),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFE1E7F0),
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

              SizedBox(height: 15),

              Container(
                padding: EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE1E7F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.phone_outlined,
                        color: Color(0xFF0A2342),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 7),
                          TextField(
                            controller: phoneController,
                            style: TextStyle(color: Color(0xFF0A2342)),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFE1E7F0),
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

              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE1E7F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.email,
                        color: Color(0xFF0A2342),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 7),
                          TextField(
                            controller: emailController,
                            style: TextStyle(color: Color(0xFF0A2342)),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFE1E7F0),
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

              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE1E7F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.local_shipping_rounded,
                        color: Color(0xFF0A2342),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Truck Number',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 7),
                          TextField(
                            controller: truckController,
                            style: TextStyle(color: Color(0xFF0A2342)),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFE1E7F0),
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

              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Color(0xFFE1E7F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Color(0xFFEAF1FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lock,
                        color: Color(0xFF0A2342),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 7),
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            style: TextStyle(color: Color(0xFF0A2342)),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color(0xFFE1E7F0),
                                ),
                              ),

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Color(0xFF0A2342),
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

              SizedBox(height: 18),

              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await saveProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF145FCC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
