import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../main.dart';

class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final TextEditingController _goalController = TextEditingController();
  bool _isLoading = false;
  static const int _maxGoalLength = 200;

  final List<String> _exampleGoals = [
    "Improve my daily mindfulness practice",
    "Build better sleep habits",
    "Maintain a positive mindset",
    "Track and improve my emotional well-being",
    "Develop a consistent daily routine",
  ];

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
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (_goalController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save goal to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userGoal', _goalController.text.trim());

      // Also update goal in Firebase user profile if logged in
      final firebaseService = FirebaseService();
      final user = firebaseService.currentUser;
      if (user != null) {
        await firebaseService.updateUserProfile(user.uid, {
          'goal': _goalController.text.trim(),
        });
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const EmotionTrackingPage(),
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

  void _useExampleGoal(String goal) {
    _goalController.text = goal;
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
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Image.asset('assets/lifelogo.png', height: 120, width: 120),
                    const SizedBox(height: 40),
                    Text(
                      'SET YOUR GOAL',
                      style: GoogleFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'What would you like to achieve?',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: Colors.grey[400],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Example Goals
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _exampleGoals.map((goal) {
                            return ActionChip(
                              label: Text(
                                goal,
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.red[900]!.withOpacity(
                                0.3,
                              ),
                              onPressed: () => _useExampleGoal(goal),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: TextField(
                        controller: _goalController,
                        style: GoogleFonts.nunito(color: Colors.white),
                        maxLines: 3,
                        maxLength: _maxGoalLength,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        decoration: InputDecoration(
                          hintText: 'Enter your goal...',
                          hintStyle: GoogleFonts.nunito(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.flag,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          counterStyle: GoogleFonts.nunito(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveGoal,
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
