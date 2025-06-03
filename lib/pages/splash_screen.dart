import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../main.dart'; // Import from main.dart since EmotionTrackingPage is defined there
import 'package:firebase_auth/firebase_auth.dart';
import '../services/stats_service.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 3));
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Not logged in, show login page
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
      return;
    }
    // Logged in, check if today's stat exists
    final statsService = StatsService();
    final todayStats = await statsService.getStatsForDate(DateTime.now());
    if (todayStats.isNotEmpty) {
      // Go to MainNavPage
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const MainNavPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      // Go to WelcomeScreen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/lifelogo.png',
                        width: 220,
                        height: 300,
                        fit: BoxFit.fitHeight,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'AUGMA LIFE',
                        style: GoogleFonts.orbitron(
                          textStyle: TextStyle(
                            color: Colors.red[900],
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.red[900]!,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/aim.png',
                    width: 34,
                    height: 34,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 24,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By Augma Imaginarium',
                    style: GoogleFonts.nunito(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
