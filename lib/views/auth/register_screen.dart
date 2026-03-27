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
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
       body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0C56B0),
              Color(0xFF2D7DDA),
              Color(0xFF66B7F3),
            ],
          
          ),
        ),
           
           child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Color(0xFFEAF3F),
                        width: 2,
                      ),
                    ),
                    child: Image.asset('assets/images/logo.png',
                       width: 86,
                       height: 86,
                       fit: BoxFit.contain,
                       color:Colors.black,
                       colorBlendMode: BlendMode.srcIn,
                    ),

                    
                  ),
                  SizedBox(height: 10),

                  Text('Create Account',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color:Colors.white
                    ),
                  
                  ),

                  SizedBox(height: 8),
                  Text('Sign up to get started',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white
                    ),
                  
                  ),
                  SizedBox(height: 20),
                 

                 
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF5D96E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: fullNameController,
                    
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.person_outline, color: Colors.white),
                      labelText: 'FullName',
                      hintText: 'Enter your Full name',
                      hintStyle: TextStyle(color: Colors.white70),
                      labelStyle: TextStyle(
                        color:Colors.white,
                        fontWeight: FontWeight.w700
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18)
                    ),
                  ),
                ),

                SizedBox(height: 18),

                Container(
                  height: 56,
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
                        color:Colors.white,
                        fontWeight: FontWeight.w700
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18)
                    ),
                  ),
                ),

                SizedBox(height: 18),
                
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF5D96E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.white70),
                      labelStyle: TextStyle(
                        color:Colors.white,
                        fontWeight: FontWeight.w700
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      }, icon: Icon(
                        obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color:Colors.white,
                      ))
                    ),
                  ),
                ),

                SizedBox(height: 18),
                

                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(0xFF5D96E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: confirmPasswordController,
                    obscureText: obscurePassword,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.white),
                      labelText: ' Confirm Password',
                      hintText: 'Confirm your password',
                      hintStyle: TextStyle(color: Colors.white70),
                      labelStyle: TextStyle(
                        color:Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 18),

                       suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          }, icon: Icon(
                            obscurePassword? Icons.visibility: Icons.visibility_off, 
                             color: Colors.white,),
                    ),
                  ),
                  
                ),



                ), 
                SizedBox(height: 14),

              

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child:ElevatedButton(
                      onPressed: (){}, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF145FCC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        )
                      ),
                    child: Text('Sign up',
                     style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                    ))
                  ),

                  SizedBox(height: 5),

                    const Divider(
                    color: Colors.white54,
                    thickness: 1,
                  ),
                  
                  const SizedBox(height: 5),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?",
                        style:TextStyle(color: Colors.white),
                      ),
                       SizedBox(width: 6,),
                      GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(context, '/home'); //CHANGE LATER
                        },
                        child: Text('Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )),
       ),
    );
  }
}