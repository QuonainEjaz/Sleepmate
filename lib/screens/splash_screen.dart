import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppConstants.splashScreen1Route);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF2A2438), // Dark purple background
        ),
        child: Center(
          child: Image.asset(
            'assets/icons/icon_large.png',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
