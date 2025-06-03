import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/stats_service.dart';
import '../main.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  final StatsService _statsService = StatsService();
  bool _isLoading = true;
  String _greeting = '';
  String _quote = '';
  int _selectedMoodLevel = 2; // Default to neutral

  // Controllers for intentions
  final List<TextEditingController> _intentionControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );

  // List of avatars for different energy levels
  final List<String> _moodLabels = [
    'Super Exhausted',
    'Tired',
    'Neutral',
    'Happy',
    'Super Happy',
  ];

  // List of emoji icons for the emotion buttons
  final List<IconData> _emotionIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_satisfied,
    Icons.sentiment_very_satisfied,
  ];

  final List<String> _quotes = [
    "Today is a new beginning in your digital wellness journey.",
    "Your future self is watching your present self take action.",
    "Every day is a chance to optimize your life metrics.",
    "Small steps today lead to quantum leaps tomorrow.",
    "Your potential is infinite, embrace each new day.",
  ];

  final List<String> _intentionHints = [
    "What's your main focus for today?",
    "What would make today great?",
    "One small step towards your goals?",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _initializeDay();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _intentionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getRandomQuote() {
    _quotes.shuffle();
    return _quotes.first;
  }

  bool _validateIntentions() {
    for (var controller in _intentionControllers) {
      if (controller.text.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  Future<void> _initializeDay() async {
    setState(() {
      _greeting = _getGreeting();
      _quote = _getRandomQuote();
    });

    try {
      // Start animations
      _controller.forward();

      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        // Remove all ScaffoldMessenger.of(context).showSnackBar usages
      }
    }
  }

  Future<void> _saveIntentionsAndContinue() async {
    if (!_validateIntentions()) {
      // Remove all ScaffoldMessenger.of(context).showSnackBar usages
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Initialize the day's stats with intentions and morning mood
      await _statsService.resetDailyStats(
        intentions:
            _intentionControllers
                .map(
                  (controller) => {
                    'text': controller.text.trim(),
                    'isCompleted': false,
                  },
                )
                .toList(),
        morningMood: _selectedMoodLevel,
      );

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
        // Remove all ScaffoldMessenger.of(context).showSnackBar usages
      }
      setState(() => _isLoading = false);
    }
  }

  // Gets the color for a specific mood level
  Color _getColorForMoodLevel(int level) {
    switch (level) {
      case 0:
        return Colors.red[300]!;
      case 1:
        return Colors.orange[300]!;
      case 2:
        return Colors.yellow[300]!;
      case 3:
        return Colors.lightGreen[300]!;
      case 4:
        return Colors.green[300]!;
      default:
        return Colors.yellow[300]!;
    }
  }

  // Build a mood selection button
  Widget _buildMoodButton(int moodLevel) {
    final isSelected = _selectedMoodLevel == moodLevel;
    final color = _getColorForMoodLevel(moodLevel);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMoodLevel = moodLevel;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: 2,
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 6,
                        ),
                      ]
                      : [],
            ),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 0),
                            ),
                          ]
                          : [],
                ),
                child: Icon(
                  _emotionIcons[moodLevel],
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _moodLabels[moodLevel].split(' ').last,
            style: GoogleFonts.nunito(
              textStyle: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSelected ? 12 : 10,
                color: isSelected ? color : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentionField(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _intentionControllers[index],
        style: GoogleFonts.nunito(color: Colors.white),
        decoration: InputDecoration(
          hintText: _intentionHints[index],
          hintStyle: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(
            Icons.lightbulb_outline,
            color: Colors.amber[700],
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    final formattedDate = dateFormat.format(now);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  Colors.red[900]!.withOpacity(0.2),
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Greeting
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Text(
                            _greeting,
                            style: GoogleFonts.orbitron(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Date
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Text(
                            formattedDate,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Quote
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red[900]!.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _quote,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (!_isLoading) ...[
                        // Morning Mood Section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Column(
                              children: [
                                Text(
                                  'HOW DID YOU WAKE UP?',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Select your morning energy level',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    5,
                                    (index) => _buildMoodButton(index),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Intentions Title
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: Column(
                              children: [
                                Text(
                                  'SET YOUR INTENTIONS',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'What would you like to achieve today?',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Intention Fields
                        ...List.generate(
                          3,
                          (index) => FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: _buildIntentionField(index),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Continue Button
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : _saveIntentionsAndContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[900],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.red[900]?.withOpacity(
                                    0.5,
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                        : Text(
                                          'START YOUR DAY',
                                          style: GoogleFonts.orbitron(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Preparing your day...',
                          style: GoogleFonts.nunito(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
