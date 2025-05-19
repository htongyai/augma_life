import 'package:flutter/material.dart';
import 'rabbit_avatar_png.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const AugmaAuraApp());
}

class AugmaAuraApp extends StatelessWidget {
  const AugmaAuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Augma Life',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.red[900]!,
          secondary: Colors.red[800]!,
          surface: Colors.white,
          background: const Color(0xFFF8F8F8),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        textTheme: TextTheme(
          // Titles with Orbitron
          titleLarge: GoogleFonts.orbitron(
            textStyle: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          titleMedium: GoogleFonts.orbitron(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Regular text with Nunito
          bodyLarge: GoogleFonts.nunito(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
          bodyMedium: GoogleFonts.nunito(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

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
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const EmotionTrackingPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF8A2387),
              const Color(0xFFE94057),
              const Color(0xFFF27121),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/avatar/bune_stage4.png', // Use a more energetic avatar
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.05),

                // Title animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Text(
                          'AUGMA LIFE',
                          style: GoogleFonts.orbitron(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: screenHeight * 0.02),

                // Tagline animation
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Text(
                          'Your digital wellness companion',
                          style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: screenHeight * 0.05),

                // Loading indicator
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EmotionTrackingPage extends StatefulWidget {
  const EmotionTrackingPage({super.key});

  @override
  State<EmotionTrackingPage> createState() => _EmotionTrackingPageState();
}

class MetricData {
  final String title;
  double value;
  final String unit;
  final double maxValue;
  final double impactWeight; // How much this impacts overall happiness (0-1)
  final double optimalValue; // The value at which this metric is most positive

  MetricData({
    required this.title,
    required this.value,
    required this.unit,
    required this.maxValue,
    required this.impactWeight,
    required this.optimalValue,
  });

  // Calculate how positive this metric is for overall wellness (0-1)
  double get positivityScore {
    // Calculate how close to optimal this value is, with a penalty for exceeding optimal
    final double distanceFromOptimal = (value - optimalValue).abs();
    final double maxDistance =
        optimalValue > value ? optimalValue : (maxValue - optimalValue);

    // Normalize to 0-1 scale
    double normalized = 1 - (distanceFromOptimal / maxDistance);

    // Ensure it stays in 0-1 range
    return normalized.clamp(0.0, 1.0);
  }

  // Formatted value for display
  String get formattedValue {
    if (title == 'Calories' || title == 'Reading') {
      return value.toInt().toString();
    } else {
      return value.toString();
    }
  }

  // Calculate progress for circular indicators
  double get progress => value / maxValue;
}

class _EmotionTrackingPageState extends State<EmotionTrackingPage>
    with SingleTickerProviderStateMixin {
  // Current selected energy level (0-4)
  // 0 = Super exhausted, 2 = Neutral, 4 = Super happy
  int _selectedEnergyLevel = 2;
  int _calculatedEnergyLevel = 2;

  // Animation controller for avatar pulsing
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // List of avatars for different energy levels
  final List<String> _avatarLabels = [
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

  // List of positive mantras
  final List<String> _mantras = [
    "I detect your potential is limitless. You can achieve anything.",
    "My sensors indicate you are getting better every day.",
    "My analysis shows you are calm, confident, and in control.",
    "I recommend choosing happiness and positive energy today.",
    "Data suggests gratitude improves human function. Be grateful for this moment.",
    "I am programmed to remind you: challenges are opportunities for growth.",
    "My primary directive is to help you be the best version of yourself.",
    "You are radiating positive energy. Keep up optimal performance.",
  ];

  // Current mantra
  late String _currentMantra;

  // All metrics data
  late List<MetricData> _metrics;

  // Store last accessed date for new day detection
  DateTime? _lastAccessDate;

  @override
  void initState() {
    super.initState();
    _currentMantra = _getRandomMantra();

    // Initialize metrics with default values (for first launch)
    _initializeMetrics();

    // Check if we need to reset for a new day
    _checkAndResetForNewDay();

    // Set up pulse animation for the avatar
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Make it pulse continuously
    _pulseController.repeat(reverse: true);

    // Calculate energy level based on metrics
    _calculateEnergyLevel();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Initialize metrics with default values
  void _initializeMetrics() {
    _metrics = [
      MetricData(
        title: 'Energy',
        value: 40.0, // Start at neutral (40) for a new day
        unit: '%',
        maxValue: 100.0,
        impactWeight: 0.3,
        optimalValue: 100.0,
      ),
      MetricData(
        title: 'Sleep',
        value: 0.0, // Reset to 0 for a new day
        unit: 'hours',
        maxValue: 10.0,
        impactWeight: 0.25,
        optimalValue: 8.0,
      ),
      MetricData(
        title: 'Calories',
        value: 0, // Reset to 0 for a new day
        unit: 'kcal',
        maxValue: 1000,
        impactWeight: 0.15,
        optimalValue: 800,
      ),
      MetricData(
        title: 'Heart',
        value: 72, // Default heart rate
        unit: 'bpm',
        maxValue: 100,
        impactWeight: 0.1,
        optimalValue: 70,
      ),
      MetricData(
        title: 'Water',
        value: 0, // Reset to 0 for a new day
        unit: 'bottles',
        maxValue: 8,
        impactWeight: 0.2,
        optimalValue: 8,
      ),
      MetricData(
        title: 'Work',
        value: 0.0, // Reset to 0 for a new day
        unit: 'hours',
        maxValue: 10,
        impactWeight: 0.15,
        optimalValue: 6.0,
      ),
      MetricData(
        title: 'Reading',
        value: 0, // Reset to 0 for a new day
        unit: 'chapters',
        maxValue: 10,
        impactWeight: 0.15,
        optimalValue: 5.0,
      ),
    ];
  }

  // Check if it's a new day and reset metrics if needed
  void _checkAndResetForNewDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // If we have a last access date and it's not today, reset everything
    if (_lastAccessDate != null) {
      final lastAccessDay = DateTime(
        _lastAccessDate!.year,
        _lastAccessDate!.month,
        _lastAccessDate!.day,
      );

      if (today.isAfter(lastAccessDay)) {
        // Reset all metrics for a new day
        setState(() {
          _initializeMetrics();
          _selectedEnergyLevel = 2; // Reset to neutral
          _calculatedEnergyLevel = 2;
          _currentMantra = _getRandomMantra(); // New day, new mantra
        });

        // Show welcome back message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome to a new day! All metrics have been reset.',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        });
      }
    }

    // Update the last access date to today
    _lastAccessDate = now;
  }

  // Calculate the energy level based on metrics
  void _calculateEnergyLevel() {
    double totalScore = 0;
    double totalWeight = 0;

    for (final metric in _metrics) {
      totalScore += metric.positivityScore * metric.impactWeight;
      totalWeight += metric.impactWeight;
    }

    // Normalize to 0-1 scale
    final overallScore = totalWeight > 0 ? totalScore / totalWeight : 0.5;

    // Map to 0-4 energy level (0=worst, 4=best)
    _calculatedEnergyLevel = (overallScore * 4).round().clamp(0, 4);

    setState(() {
      _selectedEnergyLevel = _calculatedEnergyLevel;
    });
  }

  String _getRandomMantra() {
    final random = Random();
    return _mantras[random.nextInt(_mantras.length)];
  }

  // Gets the color for a specific energy level
  Color _getColorForEnergyLevel(int level) {
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

  // Get time of day gradient
  List<Color> _getTimeOfDayGradient() {
    final hour = DateTime.now().hour;

    // Early morning (5-8)
    if (hour >= 5 && hour < 8) {
      return [
        const Color(0xFFFF9A47),
        const Color(0xFFFFC371), // Sunrise orange
      ];
    }
    // Morning (8-12)
    else if (hour >= 8 && hour < 12) {
      return [
        const Color(0xFF2F80ED),
        const Color(0xFF56CCF2), // Morning blue
      ];
    }
    // Afternoon (12-17)
    else if (hour >= 12 && hour < 17) {
      return [
        const Color(0xFF43CEA2),
        const Color(0xFF185A9D), // Afternoon green-blue
      ];
    }
    // Evening (17-20)
    else if (hour >= 17 && hour < 20) {
      return [
        const Color(0xFFf85032),
        const Color(0xFFe73827), // Evening orange-red
      ];
    }
    // Night (20-5)
    else {
      return [
        const Color(0xFF141E30),
        const Color(0xFF243B55), // Night blue
      ];
    }
  }

  // Get celestial icon based on time of day
  Widget _getCelestialIcon() {
    final hour = DateTime.now().hour;

    // Night (20-5)
    if (hour >= 20 || hour < 5) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.nightlight_round,
          color: Colors.white,
          size: 32,
        ),
      );
    }
    // Day (5-20)
    else {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.wb_sunny_rounded,
          color: Colors.amber,
          size: 32,
        ),
      );
    }
  }

  // Build an emotion selection button
  Widget _buildEmotionButton(int energyLevel) {
    final isSelected = _selectedEnergyLevel == energyLevel;
    final color = _getColorForEnergyLevel(energyLevel);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEnergyLevel = energyLevel;
          // Generate a new mantra when emotion changes
          _currentMantra = _getRandomMantra();
        });
        // Update the energy metric
        _updateEnergyMetric();
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
                  _emotionIcons[energyLevel],
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _avatarLabels[energyLevel]
                .split(' ')
                .last, // Just show "Exhausted", "Tired", etc.
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

  // Health metric card widget
  Widget _buildMetricCard({
    required MetricData metric,
    required IconData icon,
    required Color iconColor,
    bool useCircularIndicator = false,
  }) {
    return Card(
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  metric.title,
                  style: GoogleFonts.nunito(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            if (useCircularIndicator)
              _buildCircularProgress(
                value: metric.formattedValue,
                unit: metric.unit,
                progress: metric.progress,
                color: iconColor,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    metric.formattedValue,
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    metric.unit,
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Circular progress indicator for metrics
  Widget _buildCircularProgress({
    required String value,
    required String unit,
    required double progress,
    required Color color,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              unit,
              style: GoogleFonts.nunito(
                textStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Update energy metric when energy level changes
  void _updateEnergyMetric() {
    final energyMetric = _metrics.firstWhere((m) => m.title == 'Energy');
    final energyValue =
        _selectedEnergyLevel == 4 ? 100.0 : _selectedEnergyLevel * 20.0;

    setState(() {
      energyMetric.value = energyValue;
    });
  }

  // Add chapter and update energy
  void _addChapter() {
    final readingMetric = _metrics.firstWhere((m) => m.title == 'Reading');
    final energyMetric = _metrics.firstWhere((m) => m.title == 'Energy');

    // Only increment if under the max value
    if (readingMetric.value < readingMetric.maxValue) {
      setState(() {
        // Increment chapter count
        readingMetric.value += 1;

        // Add 5 energy points per chapter
        energyMetric.value = (energyMetric.value + 5).clamp(0, 100);

        // Update the selected energy level based on new energy value
        _selectedEnergyLevel = (energyMetric.value / 20).floor().clamp(0, 4);
      });

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added 1 chapter! Energy +5 points'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show max reached message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum chapters reached for today!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Add work hour and update energy
  void _addWorkHour() {
    final workMetric = _metrics.firstWhere((m) => m.title == 'Work');
    final energyMetric = _metrics.firstWhere((m) => m.title == 'Energy');

    // Only increment if under the max value
    if (workMetric.value < workMetric.maxValue) {
      setState(() {
        // Increment work hours (add 1 hour)
        workMetric.value += 1;

        // Add 5 energy points per work hour
        energyMetric.value = (energyMetric.value + 5).clamp(0, 100);

        // Update the selected energy level based on new energy value
        _selectedEnergyLevel = (energyMetric.value / 20).floor().clamp(0, 4);
      });

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added 1 hour of work! Energy +5 points'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show max reached message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum work hours reached for today!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Add water glass and update energy
  void _addWater() {
    final waterMetric = _metrics.firstWhere((m) => m.title == 'Water');
    final energyMetric = _metrics.firstWhere((m) => m.title == 'Energy');

    // Only increment if under the max value
    if (waterMetric.value < waterMetric.maxValue) {
      setState(() {
        // Increment water (add 1 glass/bottle)
        waterMetric.value += 1;

        // Add 10 energy points per glass of water
        energyMetric.value = (energyMetric.value + 10).clamp(0, 100);

        // Update the selected energy level based on new energy value
        _selectedEnergyLevel = (energyMetric.value / 20).floor().clamp(0, 4);
      });

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added 1 glass of water! Energy +10 points'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Show max reached message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum water intake reached for today!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Add new method for heart rate:
  // Update heart rate and adjust energy based on heart rate
  void _updateHeartRate(double change) {
    final heartMetric = _metrics.firstWhere((m) => m.title == 'Heart');
    final energyMetric = _metrics.firstWhere((m) => m.title == 'Energy');

    // Calculate new heart rate value (clamp between 60-200 as a reasonable range)
    double newHeartRate = (heartMetric.value + change).clamp(60, 200);

    // Only proceed if there's actual change
    if (newHeartRate != heartMetric.value) {
      // Calculate energy impact based on heart rate zones
      int energyImpact = 0;
      String message = '';

      if (newHeartRate >= 160) {
        // 160+ BPM: max heart rate zone
        energyImpact = 40;
        message = 'Maximum heart rate zone! Energy +40 points';
      } else if (newHeartRate >= 150) {
        // 150-159 BPM: high heart rate zone
        energyImpact = 30;
        message = 'High heart rate zone! Energy +30 points';
      } else if (newHeartRate >= 140) {
        // 140-149 BPM: moderate-high zone
        energyImpact = 20;
        message = 'Moderate-high heart rate zone! Energy +20 points';
      } else if (newHeartRate >= 100) {
        // 100-139 BPM: moderate zone
        energyImpact = 10;
        message = 'Moderate heart rate zone! Energy +10 points';
      } else {
        // Under 100 BPM: resting zone
        energyImpact = 0;
        message = 'Resting heart rate zone. No energy change.';
      }

      setState(() {
        // Update heart rate value
        heartMetric.value = newHeartRate;

        // Update energy with impact
        energyMetric.value = (energyMetric.value + energyImpact).clamp(0, 100);

        // Update selected energy level
        _selectedEnergyLevel = (energyMetric.value / 20).floor().clamp(0, 4);
      });

      // Provide feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Heart rate: ${newHeartRate.toInt()} BPM. $message'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Update sleep hours and adjust energy based on sleep quality
  void _updateSleepHours(double change) {
    final sleepMetric = _metrics.firstWhere((m) => m.title == 'Sleep');
    final energyMetric = _metrics.firstWhere((m) => m.title == 'Energy');

    // Calculate new sleep value
    double newSleepValue = (sleepMetric.value + change).clamp(
      0,
      sleepMetric.maxValue,
    );

    // Only proceed if there's actual change
    if (newSleepValue != sleepMetric.value) {
      // Calculate energy impact based on sleep quality
      int energyImpact = 0;
      String message = '';

      if (newSleepValue >= 8) {
        // 8+ hours: perfect sleep
        energyImpact = 0;
        message = 'Perfect sleep! No energy change.';
      } else if (newSleepValue >= 5) {
        // 5-8 hours: ideal range, no impact
        energyImpact = 0;
        message = 'Good sleep quality. No energy change.';
      } else if (newSleepValue >= 4) {
        // 4-5 hours: -20 energy
        energyImpact = -20;
        message = 'Low sleep quality. Energy -20 points!';
      } else if (newSleepValue >= 3) {
        // 3-4 hours: -30 energy
        energyImpact = -30;
        message = 'Poor sleep quality. Energy -30 points!';
      } else if (newSleepValue >= 1) {
        // 1-3 hours: -50 energy
        energyImpact = -50;
        message = 'Very poor sleep quality. Energy -50 points!';
      } else {
        // 0-1 hour: -60 energy
        energyImpact = -60;
        message = 'Extreme sleep deprivation. Energy -60 points!';
      }

      setState(() {
        // Update sleep value
        sleepMetric.value = newSleepValue;

        // Update energy with impact
        energyMetric.value = (energyMetric.value + energyImpact).clamp(0, 100);

        // Update selected energy level
        _selectedEnergyLevel = (energyMetric.value / 20).floor().clamp(0, 4);
      });

      // Provide feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sleep: ${newSleepValue.toStringAsFixed(1)} hours. $message',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Add helper methods for sleep quality:

  // Get sleep quality label based on hours
  String _getSleepQualityLabel(double hours) {
    if (hours >= 8) return 'Perfect';
    if (hours >= 5) return 'Good';
    if (hours >= 4) return 'Low';
    if (hours >= 3) return 'Poor';
    if (hours >= 1) return 'Very Poor';
    return 'Critical';
  }

  // Get sleep quality color based on hours
  Color _getSleepQualityColor(double hours) {
    if (hours >= 8) return Colors.green;
    if (hours >= 5) return Colors.lightGreen;
    if (hours >= 4) return Colors.orange;
    if (hours >= 3) return Colors.deepOrange;
    if (hours >= 1) return Colors.red[300]!;
    return Colors.red[900]!;
  }

  // Get heart rate zone label based on bpm
  String _getHeartRateZoneLabel(double bpm) {
    if (bpm >= 160) return 'Maximum Heart Rate Zone';
    if (bpm >= 150) return 'High Heart Rate Zone';
    if (bpm >= 140) return 'Moderate-High Heart Rate Zone';
    if (bpm >= 100) return 'Moderate Heart Rate Zone';
    return 'Resting Heart Rate Zone';
  }

  // Get heart rate zone color based on bpm
  Color _getHeartRateZoneColor(double bpm) {
    if (bpm >= 160) return Colors.red;
    if (bpm >= 150) return Colors.orange;
    if (bpm >= 140) return Colors.deepOrange;
    if (bpm >= 100) return Colors.amber;
    return Colors.green;
  }

  // Add new method for calories:
  void _addCalories(int amount) {
    final caloriesMetric = _metrics.firstWhere((m) => m.title == 'Calories');
    final energyMetric = _metrics.firstWhere((m) => m.title == 'Energy');

    // Only increment if under the max value
    double newCalories = (caloriesMetric.value + amount).clamp(
      0,
      caloriesMetric.maxValue,
    );

    if (newCalories != caloriesMetric.value) {
      setState(() {
        // Update calories value
        caloriesMetric.value = newCalories;

        // Add energy points based on calories (10 energy points per 100 calories)
        double energyPoints = (amount / 100) * 10;
        if (energyPoints > 0) {
          energyMetric.value = (energyMetric.value + energyPoints).clamp(
            0,
            100,
          );

          // Update selected energy level
          _selectedEnergyLevel = (energyMetric.value / 20).floor().clamp(0, 4);
        }
      });

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $amount calories! Energy +${(amount / 100 * 10).toInt()} points',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Always check for new day when building UI
    _checkAndResetForNewDay();

    // Get current date
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM');
    final formattedDate = dateFormat.format(now);
    final screenWidth = MediaQuery.of(context).size.width;

    // Get time of day gradient colors
    final gradientColors = _getTimeOfDayGradient();

    // Find metrics by title
    final sleepMetric = _metrics.firstWhere((m) => m.title == 'Sleep');
    final caloriesMetric = _metrics.firstWhere((m) => m.title == 'Calories');
    final heartMetric = _metrics.firstWhere((m) => m.title == 'Heart');
    final waterMetric = _metrics.firstWhere((m) => m.title == 'Water');
    final workMetric = _metrics.firstWhere((m) => m.title == 'Work');
    final readingMetric = _metrics.firstWhere((m) => m.title == 'Reading');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with greeting and date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // App name in header (Orbitron)
                          Text(
                            'Hi, Ham',
                            style: GoogleFonts.orbitron(
                              textStyle: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Welcome message (Nunito)
                          Text(
                            'Welcome back to Augma Life',
                            style: GoogleFonts.orbitron(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Action button moved to header
                      FloatingActionButton(
                        onPressed: () {
                          // Save the selected energy level as the calculated value
                          setState(() {
                            _calculatedEnergyLevel = _selectedEnergyLevel;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Saved your energy level: ${_avatarLabels[_selectedEnergyLevel]}',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        backgroundColor: Colors.red[900],
                        mini: true, // Make it smaller
                        elevation: 2,
                        child: const Icon(Icons.save, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Avatar section with time-of-day gradient
                Card(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Date (Nunito)
                          const SizedBox(height: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Title (Orbitron)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Your Wellness Avatar',
                                    style: GoogleFonts.orbitron(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              _getCelestialIcon(),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Energy Level Indicator
                          Row(
                            children: [
                              Text(
                                'ENERGY:',
                                style: GoogleFonts.orbitron(
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value:
                                        _selectedEnergyLevel /
                                        4, // Convert to 0.0-1.0 range
                                    minHeight: 8,
                                    backgroundColor: Colors.white24,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getColorForEnergyLevel(
                                        _selectedEnergyLevel,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_selectedEnergyLevel == 4 ? 100 : _selectedEnergyLevel * 20}',
                                  style: GoogleFonts.orbitron(
                                    textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: screenWidth * 0.5, // Even smaller height
                            width: screenWidth * 0.45, // Slightly smaller width
                            child: Center(
                              child: ScaleTransition(
                                scale: _pulseAnimation,
                                child: RabbitAvatarPng(
                                  energyLevel: _selectedEnergyLevel,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Magna feels ${_avatarLabels[_selectedEnergyLevel].toLowerCase()} today",
                            style: GoogleFonts.nunito(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Based on metrics (Nunito)
                          Text(
                            "Based on your metrics",
                            style: GoogleFonts.nunito(
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mantra box moved inside the avatar card
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // BUN-E label (Orbitron)
                                    Text(
                                      "Magna:",
                                      style: GoogleFonts.orbitron(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _currentMantra = _getRandomMantra();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _currentMantra,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Emotion selection section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Emotion question (Orbitron)
                            Text(
                              'How is your energy today?',
                              style: GoogleFonts.orbitron(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.energy_savings_leaf,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Emotion buttons row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              5,
                              (index) => _buildEmotionButton(index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Metrics section title (Orbitron)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    'Today\'s Metrics',
                    style: GoogleFonts.orbitron(
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                      ),
                    ),
                  ),
                ),

                // Metrics grid
                GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  padding: EdgeInsets.zero,
                  children: [
                    // Sleep metric with simple add button
                    Card(
                      margin: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sleep',
                                  style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.nightlight_round,
                                  color: Colors.indigo,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Sleep value display
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    '${sleepMetric.value.toStringAsFixed(1)}',
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    sleepMetric.unit,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Add Sleep button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _updateSleepHours(1.0),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('+ Add Sleep'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Energy impact info
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Center(
                                child: Text(
                                  '5-8 hours optimal',
                                  style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.indigo[300],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Calories metric with single add button
                    Card(
                      margin: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Calories',
                                  style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    caloriesMetric.formattedValue,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    caloriesMetric.unit,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Add Calories button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _addCalories(50),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('+ Add Calories'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Energy info
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Center(
                                child: Text(
                                  '+10 energy per 100 calories',
                                  style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange[300],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Heart rate metric with simple add button
                    Card(
                      margin: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Heart',
                                  style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.favorite,
                                  color: Colors.red[900],
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    heartMetric.formattedValue,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    heartMetric.unit,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Single add button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _updateHeartRate(10),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[900],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('+ Add Heart Rate'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Energy info
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Center(
                                child: Text(
                                  'Energy varies by zone',
                                  style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red[300],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Water intake metric with add button
                    Card(
                      margin: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Water',
                                  style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    waterMetric.formattedValue,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    waterMetric.unit,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Button at the bottom
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _addWater,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('+ Add Glass'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Energy bonus info
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Center(
                                child: Text(
                                  '+10 energy per glass',
                                  style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue[300],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Work hours metric with add button
                    Card(
                      margin: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Work',
                                  style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Icon(Icons.work, color: Colors.brown, size: 20),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    workMetric.formattedValue,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    workMetric.unit,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Button at the bottom
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _addWorkHour,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('+ Add Hour'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Energy bonus info
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Center(
                                child: Text(
                                  '+5 energy per hour',
                                  style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.brown[300],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Reading chapters metric with add button
                    Card(
                      margin: const EdgeInsets.all(6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Reading',
                                  style: GoogleFonts.nunito(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.menu_book,
                                  color: Colors.teal,
                                  size: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    readingMetric.formattedValue,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    readingMetric.unit,
                                    style: GoogleFonts.nunito(
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Button at the bottom
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _addChapter,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text('+ Add Chapter'),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Energy bonus info
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Center(
                                child: Text(
                                  '+5 energy per chapter',
                                  style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.teal[300],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 80), // Bottom padding for FAB
              ],
            ),
          ),
        ),
      ),
    );
  }
}
