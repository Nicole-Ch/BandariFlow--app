import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override

  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      
      Navigator.pushReplacementNamed(context, '/login');
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:  Container(
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
              ])
           ),

           child:Stack(
            children: [
              Positioned(
                top: -40,
                left: -30,
                child: Container(
                   width: 180,
                   height: 180,
                   decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFD9ECFF),
                   ),
              )
              ),

              Positioned(
                top: 400,
                right: -55,
                child: Container(
                  width: 180,
                   height: 180,
                   decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE7EEF7),
                   ),
              )),


               Positioned(
                bottom: -70,
                left: -40,
                child: Container(
                  width: 240,
                   height: 240,
                   decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFCFEFFF),
                   ),
              )),



              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border:Border.all(
                              color: Color(0xFFEAF3FF),
                              width: 2),
                              
                          ),
                          child: Image.asset('assets/images/logo.png',
                               width: 210,
                               height: 210,
                               fit: BoxFit.contain,
                               color: Colors.black,
                               colorBlendMode: BlendMode.srcIn,
                          ),
                        ),

                        SizedBox(height: 10,),
                        Text('BandariFlow',
                           style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800
                           ),
                        ),
                        SizedBox(height: 10,),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child:CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          )
                        )


                       ],
                                  ),
                  ),
                ))
            ],
           ),
      ),
    );
  }
}