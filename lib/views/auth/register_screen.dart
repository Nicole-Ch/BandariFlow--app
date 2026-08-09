import 'package:bandariflow/services/api_service.dart';
import 'package:bandariflow/views/auth/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeTerms = false;

  Future<void> registerUser() async {
    // Validate before making API call
    if (fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!emailController.text.trim().contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid email address (e.g., name@example.com)',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final result = await ApiService.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print('REGISTER ERROR: $e');

      String errorMessage = 'Registration failed. Please try again.';

      // Parse the error response from Django
      final errorString = e.toString();

      if (errorString.contains('email')) {
        if (errorString.contains('valid email')) {
          errorMessage =
              'Please enter a valid email address (e.g., name@example.com)';
        } else if (errorString.contains('already exists')) {
          errorMessage =
              'This email is already registered. Please login instead.';
        }
      } else if (errorString.contains('password')) {
        if (errorString.contains('at least 6 characters')) {
          errorMessage = 'Password must be at least 6 characters long.';
        }
      } else if (errorString.contains('confirm_password')) {
        errorMessage = 'Passwords do not match. Please try again.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C56B0), Color(0xFF2D7DDA), Color(0xFF66B7F3)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 86,
                    height: 86,
                    fit: BoxFit.contain,
                    color: Colors.black,
                    colorBlendMode: BlendMode.srcATop,
                  ),
                ),
                SizedBox(height: 10),

                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: 8),
                Text(
                  'Sign up to get started',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF5D96E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: fullNameController,

                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      labelText: 'FullName',
                      hintText: 'Enter your Full name',
                      hintStyle: TextStyle(color: Colors.white70),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),

                SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF5D96E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.mail_outline, color: Colors.white),
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.white70),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),

                SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF5D96E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.white70),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
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
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 18),

                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF5D96E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                      labelText: ' Confirm Password',
                      hintText: 'Confirm your password',
                      hintStyle: TextStyle(color: Colors.white70),
                      labelStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF145FCC),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 5),

                const Divider(color: Colors.white54, thickness: 1),

                const SizedBox(height: 5),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login'); //CHANGE LATER
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
