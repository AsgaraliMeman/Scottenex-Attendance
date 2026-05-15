import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'AUTHENTICATING SESSION',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SplashIcon(),
                    SizedBox(height: 40),
                    Text(
                      'Attendance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Enterprise Management System',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shield, color: Colors.white54, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'POWERED BY WIFI & GPS VERIFICATION',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashIcon extends StatelessWidget {
  const _SplashIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      height: 156,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.24),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.watch_later, size: 72, color: Colors.black),
      ),
    );
  }
}
