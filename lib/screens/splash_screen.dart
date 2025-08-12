import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';// For loading animation
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          children: <Widget>[
            // Background layer - launch image covering full screen
            Positioned.fill(
              child: Image.asset(
                'assets/images/launch_image.png',
                fit: BoxFit.cover,
              ),
            ),
            // Foreground layer - centered loading spinner
            const Center(
              child: SpinKitCircle(
                color: Color(0xFF539765),
                size: 50.0,
              ),
            ),
          ],
         ),
       ),
      );
  }
}