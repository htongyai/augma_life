import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/firebase_service.dart';
import 'goal_setting_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAvatarName() async {
    if (_nameController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save avatar name to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatarName', _nameController.text.trim());

      // Also update avatarName in Firebase user profile if logged in
      final firebaseService = FirebaseService();
      final user = firebaseService.currentUser;
      if (user != null) {
        await firebaseService.updateUserProfile(user.uid, {
          'avatarName': _nameController.text.trim(),
        });
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const GoalSettingScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.black,
                Colors.red[900]!.withOpacity(0.3),
                Colors.black,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/lifelogo.png', height: 120, width: 120),
                    const SizedBox(height: 40),
                    Text(
                      'NAME YOUR AVATAR',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your digital companion awaits its identity',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.nunito(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter avatar name',
                          hintStyle: GoogleFonts.nunito(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.pets,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAvatarName,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[900],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          shadowColor: Colors.red[900]?.withOpacity(0.5),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  'CONTINUE',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
