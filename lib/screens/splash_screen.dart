import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  static const Duration _splashDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    _timer = Timer(_splashDuration, () {
      if (mounted) {
        _navigateToMain();
      }
    });
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontSize: 64,
      fontWeight: FontWeight.bold,
      color: AppColors.white,
    );
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'B'),
                  TextSpan(text: 'ite'),
                  TextSpan(text: 'i', style: TextStyle(color: AppColors.accentYellow)),
                  TextSpan(text: 'te'),
                ],
                style: baseStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}