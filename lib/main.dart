import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'rabbit_avatar_png.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:math' hide min, max;
import 'dart:math' as math show min, max;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/stats_service.dart';
import 'services/firebase_service.dart';
import 'health_service.dart';
import 'widgets/date_selector.dart';
import 'widgets/gender_selector.dart';
import 'pages/welcome_screen.dart';
import 'pages/onboarding_screen.dart';
import 'pages/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/edit_profile_page.dart';
import 'pages/change_password_page.dart';
import 'pages/about_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'widgets/settings_tile.dart';
import 'widgets/settings_switch.dart';
import 'widgets/settings_section.dart';
import 'pages/debug_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> requestNotificationPermissions() async {
  // Android permissions are granted at install, but iOS needs explicit request
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >()
      ?.requestPermissions(alert: true, badge: true, sound: true);
}

Future<void> scheduleDailyNotifications() async {
  final List<Map<String, dynamic>> notifications = [
    {
      'id': 0,
      'hour': 6,
      'minute': 0,
      'title': 'Start your day!',
      'body': 'Check in with your Bunn-E!',
    },
    {
      'id': 1,
      'hour': 9,
      'minute': 0,
      'title': 'Set your intentions',
      'body': 'Have you set your intentions for the day?',
    },
    {
      'id': 2,
      'hour': 16,
      'minute': 0,
      'title': 'Daily Check',
      'body': 'Have you read, worked, or exercised yet?',
    },
    {
      'id': 3,
      'hour': 18,
      'minute': 0,
      'title': 'Evening Sync',
      'body': 'How was your day? Sync with your Bunn-E.',
    },
    {
      'id': 4,
      'hour': 20,
      'minute': 0,
      'title': 'Log your day',
      'body':
          'Hope you had a great day! Don\'t forget to log how your day went!',
    },
    {
      'id': 4,
      'hour': 21,
      'minute': 31,
      'title': 'Log your day',
      'body':
          'Hope you had a great day! Don\'t forget to log how your day went!',
    },
  ];

  for (var notif in notifications) {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notif['id'],
      notif['title'],
      notif['body'],
      _nextInstanceOfTime(notif['hour'], notif['minute']),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Daily Reminders',
          channelDescription: 'Daily reminders for wellness check-ins',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    hour,
    minute,
  );
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  return scheduledDate;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await initializeNotifications();
  await requestNotificationPermissions();
  await scheduleDailyNotifications();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          },
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

class MainNavPage extends StatefulWidget {
  const MainNavPage({super.key});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _selectedIndex = 0;
  final FirebaseService _firebaseService = FirebaseService();

  late ScrollController _scrollController;
  bool _showNavBar = true;
  double _lastOffset = 0;
  bool _immersiveMode = false;

  @override
  void initState() {
    super.initState();
    _fetchAndStoreUserInfo();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadImmersiveMode();
  }

  Future<void> _loadImmersiveMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _immersiveMode = prefs.getBool('immersiveMode') ?? false;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.position.pixels;
    if (offset > _lastOffset + 8 && _showNavBar) {
      // Scrolling down
      setState(() => _showNavBar = false);
    } else if (offset < _lastOffset - 8 && !_showNavBar) {
      // Scrolling up
      setState(() => _showNavBar = true);
    }
    _lastOffset = offset;
  }

  Future<void> _fetchAndStoreUserInfo() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      final profile = await _firebaseService.getUserProfile(user.uid);
      if (profile != null && profile['name'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', profile['name']);
      }
    }
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return EmotionTrackingPage(
          scrollController: _scrollController,
          immersiveMode: _immersiveMode,
        );
      case 1:
        return StatsPage(scrollController: _scrollController);
      case 2:
        return DailyGoalPage(scrollController: _scrollController);
      default:
        return EmotionTrackingPage(
          scrollController: _scrollController,
          immersiveMode: _immersiveMode,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content swaps based on selected index
          Positioned.fill(
            child: Column(
              children: [
                // const SizedBox(height: 24), // Top padding
                Expanded(child: _buildPage()),
              ],
            ),
          ),
          // Floating Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _showNavBar ? Offset.zero : const Offset(0, 1),
              curve: Curves.easeInOut,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(120),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = 0);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.home_rounded,
                                color:
                                    _selectedIndex == 0
                                        ? Colors.red[900]
                                        : Colors.grey,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Home',
                                style: GoogleFonts.nunito(
                                  color:
                                      _selectedIndex == 0
                                          ? Colors.red[900]
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 36),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = 1);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                color:
                                    _selectedIndex == 1
                                        ? Colors.red[900]
                                        : Colors.grey,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stats',
                                style: GoogleFonts.nunito(
                                  color:
                                      _selectedIndex == 1
                                          ? Colors.red[900]
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 36),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = 2);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.flag,
                                color:
                                    _selectedIndex == 2
                                        ? Colors.red[900]
                                        : Colors.grey,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Goals',
                                style: GoogleFonts.nunito(
                                  color:
                                      _selectedIndex == 2
                                          ? Colors.red[900]
                                          : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const SplashScreen(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.nunito()),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Title
                    Image.asset('assets/lifelogo.png', height: 120, width: 120),
                    const SizedBox(height: 24),
                    Text(
                      'AUGMA LIFE',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        textStyle: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back to the future',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                                  'LOGIN',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Link
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const SignUpPage(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(
                              milliseconds: 500,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'New to Augma Life? Sign Up',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.nunito(color: Colors.white),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedBirthDate == null ||
        _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.red[900],
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match', style: GoogleFonts.nunito()),
          backgroundColor: Colors.red[900],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        birthDate: _selectedBirthDate!,
        gender: _selectedGender!,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const OnboardingScreen(),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.nunito()),
            backgroundColor: Colors.red[900],
          ),
        );
      }
    } finally {
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      'CREATE ACCOUNT',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        textStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join the future of wellness',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Name Field
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Birth Date Selector
                    DateSelector(
                      selectedDate: _selectedBirthDate,
                      onDateSelected: (date) {
                        setState(() => _selectedBirthDate = date);
                      },
                      label: 'Birth Date',
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    ),
                    const SizedBox(height: 16),

                    // Gender Selector
                    GenderSelector(
                      selectedGender: _selectedGender,
                      onGenderSelected: (gender) {
                        setState(() => _selectedGender = gender);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),

                    // Sign Up Button
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
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
                                  'SIGN UP',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.nunito(color: Colors.white),
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// Intention class to store intention data
class Intention {
  String text;
  bool isCompleted;

  Intention({required this.text, this.isCompleted = false});

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {'text': text, 'isCompleted': isCompleted};
  }

  // Create from map for retrieval
  factory Intention.fromMap(Map<String, dynamic> map) {
    return Intention(
      text: map['text'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class StatsPage extends StatefulWidget {
  final ScrollController? scrollController;
  const StatsPage({super.key, this.scrollController});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final StatsService _statsService = StatsService();
  List<Map<String, dynamic>> _dailyStats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      // Get stats for the last 7 days
      final now = DateTime.now();
      final stats = await Future.wait(
        List.generate(7, (index) {
          final date = now.subtract(Duration(days: index));
          return _statsService.getStatsForDate(date);
        }),
      );

      setState(() {
        _dailyStats =
            stats.asMap().entries.map((entry) {
              final date = now.subtract(Duration(days: entry.key));
              return {'date': date, 'stats': entry.value};
            }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading stats: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // For aura color and icon
    final List<String> auraLabels = [
      'Exhausted',
      'Tired',
      'Neutral',
      'Happy',
      'Super Happy',
    ];
    final List<IconData> auraIcons = [
      Icons.sentiment_very_dissatisfied,
      Icons.sentiment_dissatisfied,
      Icons.sentiment_neutral,
      Icons.sentiment_satisfied,
      Icons.sentiment_very_satisfied,
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Daily Stats',
                style: GoogleFonts.orbitron(
                  textStyle: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Stats List
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                        onRefresh: _loadStats,
                        child: ListView.builder(
                          controller: widget.scrollController,
                          itemCount: _dailyStats.length,
                          itemBuilder: (context, index) {
                            final data = _dailyStats[index];
                            final date = data['date'] as DateTime;
                            final stats = data['stats'] as Map<String, dynamic>;
                            final intentions =
                                (stats['intentions'] as List?)
                                    ?.map(
                                      (i) => Intention.fromMap(
                                        Map<String, dynamic>.from(i),
                                      ),
                                    )
                                    .toList() ??
                                [];
                            final gratitudeList =
                                (stats['gratitude'] as List?) ?? [];
                            final energyValue =
                                (stats['energy'] as num?)?.toInt() ?? 0;
                            final auraLevel = (energyValue / 25).floor().clamp(
                              0,
                              4,
                            );
                            final auraColor = _getColorForEnergyLevel(
                              auraLevel,
                            );
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Date and energy badge
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'EEEE, MMM d, yyyy',
                                          ).format(date),
                                          style: GoogleFonts.orbitron(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: auraColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                auraIcons[auraLevel],
                                                color: auraColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '$energyValue',
                                                style: GoogleFonts.orbitron(
                                                  color: auraColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Energy progress bar
                                    LinearProgressIndicator(
                                      value: energyValue / 100.0,
                                      minHeight: 8,
                                      backgroundColor: auraColor.withOpacity(
                                        0.1,
                                      ),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        auraColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          auraIcons[auraLevel],
                                          color: auraColor,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          auraLabels[auraLevel],
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: auraColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    // Intentions & Gratitude side by side
                                    if (intentions.isNotEmpty ||
                                        gratitudeList.isNotEmpty) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Intentions
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Intentions',
                                                  style: GoogleFonts.orbitron(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                ...intentions.map(
                                                  (i) => Row(
                                                    children: [
                                                      Icon(
                                                        i.isCompleted
                                                            ? Icons.check_box
                                                            : Icons
                                                                .check_box_outline_blank,
                                                        size: 18,
                                                        color:
                                                            i.isCompleted
                                                                ? Colors.green
                                                                : Colors.grey,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          i.text,
                                                          style: GoogleFonts.nunito(
                                                            fontSize: 13,
                                                            color:
                                                                i.isCompleted
                                                                    ? Colors
                                                                        .green[800]
                                                                    : Colors
                                                                        .black87,
                                                            decoration:
                                                                i.isCompleted
                                                                    ? TextDecoration
                                                                        .lineThrough
                                                                    : null,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Divider
                                          Container(
                                            width: 1,
                                            height: 48,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            color: Colors.grey[300],
                                          ),
                                          // Gratitude
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Gratitude',
                                                  style: GoogleFonts.orbitron(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                ...gratitudeList.map(
                                                  (g) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 2,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            g['text'] ?? '',
                                                            style: GoogleFonts.nunito(
                                                              fontSize: 13,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                    // Metrics grid
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 8,
                                      children: [
                                        _buildMetricStat(
                                          'Sleep',
                                          stats['sleep'],
                                          'hours',
                                          Icons.nightlight_round,
                                          Colors.indigo,
                                        ),
                                        _buildMetricStat(
                                          'Water',
                                          stats['water'],
                                          'glasses',
                                          Icons.water_drop,
                                          Colors.blue,
                                        ),
                                        _buildMetricStat(
                                          'Work',
                                          stats['work'],
                                          'hours',
                                          Icons.work,
                                          Colors.brown,
                                        ),
                                        _buildMetricStat(
                                          'Reading',
                                          stats['reading'],
                                          'chapters',
                                          Icons.menu_book,
                                          Colors.teal,
                                        ),
                                        _buildMetricStat(
                                          'Calories',
                                          stats['calories'],
                                          'kcal',
                                          Icons.local_fire_department,
                                          Colors.orange,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricStat(
    String label,
    dynamic value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            value != null ? value.toString() : '-',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            unit,
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // Add this helper for aura color
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
}

class EmotionTrackingPage extends StatefulWidget {
  final ScrollController? scrollController;
  final bool immersiveMode;
  const EmotionTrackingPage({
    super.key,
    this.scrollController,
    this.immersiveMode = false,
  });

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

  // List for intentions
  List<Intention> _intentions = [
    Intention(text: 'Write your first intention here'),
    Intention(text: 'Write your second intention here'),
    Intention(text: 'Write your third intention here'),
  ];

  // Animation controller for avatar pulsing
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Stats service
  final StatsService _statsService = StatsService();

  // Stream subscriptions
  StreamSubscription? _statsSubscription;
  StreamSubscription? _intentionsSubscription;

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

    // Initialize metrics with default values
    _initializeMetrics();

    // Set up pulse animation for the avatar with try-catch
    try {
      _pulseController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );

      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      );

      // Make it pulse continuously
      _pulseController.repeat(reverse: true);
    } catch (e) {
      print('Error setting up pulse animation: $e');
    }

    // Load data from Firebase
    _loadDataFromFirebase();

    _setupStreams();
  }

  // Load data from Firebase
  Future<void> _loadDataFromFirebase() async {
    try {
      print('🔄 Starting to load data from Firebase...');
      // Get today's stats
      final todayStats = await _statsService.getStatsForDate(DateTime.now());
      print('📊 Retrieved stats from Firebase: $todayStats');

      if (todayStats.isNotEmpty) {
        print('✅ Found existing data for today');
        setState(() {
          // Load energy from Firebase
          if (todayStats.containsKey('energy')) {
            final energyValue = todayStats['energy'] as num;
            // Convert energy value to level (0-100 -> 0-4)
            // Map 0-25 to 0, 26-50 to 1, 51-75 to 2, 76-100 to 3-4
            _selectedEnergyLevel = (energyValue / 25).floor().clamp(0, 4);
            _calculatedEnergyLevel = _selectedEnergyLevel;
            print(
              '⚡ Energy loaded from Firebase: $energyValue -> Level: $_selectedEnergyLevel',
            );
          } else if (todayStats.containsKey('morningMood')) {
            _selectedEnergyLevel = todayStats['morningMood'] as int;
            _calculatedEnergyLevel = _selectedEnergyLevel;
            print(
              '🌅 Energy level set from morning mood: $_selectedEnergyLevel',
            );
          }

          // Load metrics
          for (final metric in _metrics) {
            final key = metric.title.toLowerCase();
            if (todayStats.containsKey(key)) {
              metric.value = (todayStats[key] as num).toDouble();
              print('📈 Loaded ${metric.title}: ${metric.value}');
            }
          }

          // Load intentions
          if (todayStats.containsKey('intentions')) {
            final intentionsList = todayStats['intentions'] as List;
            _intentions =
                intentionsList
                    .map((i) => Intention.fromMap(Map<String, dynamic>.from(i)))
                    .toList();
            print('📝 Loaded ${_intentions.length} intentions');
          }

          // Update current mantra based on energy level
          _currentMantra = _getRandomMantra();
          print('💭 Updated mantra based on energy level');
        });
      } else {
        print('⚠️ No data found for today, initializing new day');
        // If no data exists for today, initialize new day
        _initializeNewDay();
      }
    } catch (e) {
      print('❌ Error loading data from Firebase: $e');
      // Initialize new day if there's an error
      _initializeNewDay();
    }
  }

  // Initialize a new day
  Future<void> _initializeNewDay() async {
    print('🆕 Initializing new day...');
    setState(() {
      // Reset metrics
      _initializeMetrics();
      print('📊 Metrics initialized');

      // Reset energy levels
      _selectedEnergyLevel = 0;
      _calculatedEnergyLevel = 0;
      print('⚡ Energy levels reset to 0');

      // Reset intentions
      _resetIntentions();
      print('📝 Intentions reset');

      // Update current mantra
      _currentMantra = _getRandomMantra();
      print('💭 Updated mantra for new day');
    });

    // Save initial state to Firebase
    await _statsService.resetDailyStats(
      morningMood: _selectedEnergyLevel,
      intentions: _intentions.map((i) => i.toMap()).toList(),
    );
    print('💾 Initial state saved to Firebase');

    // Show welcome message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to a new day! All stats have been reset.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Reset intentions for a new day
  void _resetIntentions() {
    _intentions = [
      Intention(text: 'Write your first intention here'),
      Intention(text: 'Write your second intention here'),
      Intention(text: 'Write your third intention here'),
    ];
  }

  // Toggle intention completion status
  void _toggleIntention(int index) {
    final intention = _intentions[index];
    final wasCompleted = intention.isCompleted;

    // Update intention locally first
    setState(() {
      intention.isCompleted = !wasCompleted;
    });

    // Update both intentions and stats in Firestore
    _statsService.updateIntentions(_intentions.map((i) => i.toMap()).toList());

    // Add 10 energy points when an intention is checked
    if (!wasCompleted) {
      final energyMetric = _metrics.firstWhere((m) => m.title == 'Energy');
      final newEnergyValue = math.min(100.0, energyMetric.value + 10.0);

      setState(() {
        energyMetric.value = newEnergyValue;
        // Update energy level based on new value
        _selectedEnergyLevel = (newEnergyValue / 25).floor().clamp(0, 4);
      });

      // Update energy in Firebase
      _statsService.updateStat('energy', newEnergyValue);

      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Intention completed! +10 energy points'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Edit intention text
  void _editIntention(int index) {
    final TextEditingController controller = TextEditingController(
      text: _intentions[index].text,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Edit Intention',
              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter your intention',
                border: OutlineInputBorder(),
              ),
              maxLength: 50,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    setState(() {
                      _intentions[index].text = controller.text.trim();
                    });
                    // Update intentions in Firebase
                    _statsService.updateIntentions(
                      _intentions.map((i) => i.toMap()).toList(),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                ),
                child: Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  void _setupStreams() {
    // Listen to stats updates
    _statsSubscription = _statsService.getUserStatsStream().listen((stats) {
      if (mounted) {
        setState(() {
          // Update metrics from stats
          for (var metric in _metrics) {
            if (stats.containsKey(metric.title.toLowerCase())) {
              metric.value = stats[metric.title.toLowerCase()].toDouble();
            }
          }

          // Update energy level based on morning mood or current energy
          if (stats.containsKey('morningMood')) {
            final morningMood = stats['morningMood'] as int;
            _selectedEnergyLevel = morningMood;
          } else if (stats.containsKey('energy')) {
            final energyValue = stats['energy'].toDouble();
            _selectedEnergyLevel = (energyValue / 20).floor().clamp(0, 4);
          }

          // Show feedback for updates
          if (stats.containsKey('lastUpdated')) {
            final metric = stats.entries.firstWhere(
              (e) => e.key != 'lastUpdated' && e.key != 'energy',
              orElse: () => MapEntry('', null),
            );

            if (metric.key.isNotEmpty) {
              String message = '';
              switch (metric.key) {
                case 'water':
                  message = 'Added 1 glass of water! Energy +10 points';
                  break;
                case 'reading':
                  message = 'Added 1 chapter! Energy +5 points';
                  break;
                case 'work':
                  message = 'Added 1 hour of work! Energy +5 points';
                  break;
                case 'calories':
                  final calories = metric.value;
                  message =
                      'Added $calories calories! Energy +${(calories / 100 * 10).toInt()} points';
                  break;
                case 'sleep':
                  final sleep = metric.value;
                  String quality = '';
                  if (sleep >= 8)
                    quality = 'Perfect sleep!';
                  else if (sleep >= 5)
                    quality = 'Good sleep quality';
                  else if (sleep >= 4)
                    quality = 'Low sleep quality. Energy -20 points!';
                  else if (sleep >= 3)
                    quality = 'Poor sleep quality. Energy -30 points!';
                  else if (sleep >= 1)
                    quality = 'Very poor sleep quality. Energy -50 points!';
                  else
                    quality = 'Extreme sleep deprivation. Energy -60 points!';
                  message =
                      'Sleep: ${sleep.toStringAsFixed(1)} hours. $quality';
                  break;
              }

              if (message.isNotEmpty && mounted) {
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text(message),
                //     duration: const Duration(seconds: 2),
                //   ),
                // );
              }
            }
          }
        });
      }
    });

    // Listen to intentions updates
    _intentionsSubscription = _statsService.getIntentionsStream().listen((
      intentions,
    ) {
      if (mounted) {
        setState(() {
          _intentions = intentions.map((i) => Intention.fromMap(i)).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statsSubscription?.cancel();
    _intentionsSubscription?.cancel();
    super.dispose();
  }

  // Initialize metrics with default values
  void _initializeMetrics() {
    _metrics = [
      MetricData(
        title: 'Energy',
        value: 0.0, // Start at 0 for a new day
        unit: '%',
        maxValue: 100.0,
        impactWeight: 0.3,
        optimalValue: 100.0,
      ),
      MetricData(
        title: 'Sleep',
        value: 0.0,
        unit: 'hours',
        maxValue: 10.0,
        impactWeight: 0.25,
        optimalValue: 8.0,
      ),
      MetricData(
        title: 'Calories',
        value: 0,
        unit: 'kcal',
        maxValue: 1000,
        impactWeight: 0.15,
        optimalValue: 800,
      ),
      MetricData(
        title: 'Heart',
        value: 0, // Start at 0 until health data is loaded
        unit: 'bpm',
        maxValue: 100,
        impactWeight: 0.1,
        optimalValue: 70,
      ),
      MetricData(
        title: 'Water',
        value: 0,
        unit: 'bottles',
        maxValue: 8,
        impactWeight: 0.2,
        optimalValue: 8,
      ),
      MetricData(
        title: 'Work',
        value: 0.0,
        unit: 'hours',
        maxValue: 10,
        impactWeight: 0.15,
        optimalValue: 6.0,
      ),
      MetricData(
        title: 'Reading',
        value: 0,
        unit: 'chapters',
        maxValue: 10,
        impactWeight: 0.15,
        optimalValue: 5.0,
      ),
    ];

    // Calculate energy level based on metrics
    _calculateEnergyLevel();
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
        _initializeNewDay();
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

    // Update selected energy level if it's different from calculated
    if (_selectedEnergyLevel != _calculatedEnergyLevel) {
      _selectedEnergyLevel = _calculatedEnergyLevel;
      print('⚡ Energy level updated to $_selectedEnergyLevel based on metrics');
    }
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

    // Early morning (6-8)
    if (hour >= 6 && hour < 8) {
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
    // Evening (17-19)
    else if (hour >= 17 && hour < 19) {
      return [
        const Color(0xFFf85032),
        const Color(0xFFe73827), // Evening orange-red
      ];
    }
    // Night (19-6)
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

    // Night (19-6)
    if (hour >= 19 || hour < 6) {
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
    // Day (6-19)
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

  // Build an emotion selection button - updated to be non-interactive
  Widget _buildEmotionButton(int energyLevel, {bool isInteractive = true}) {
    final isSelected = _selectedEnergyLevel == energyLevel;
    final color = _getColorForEnergyLevel(energyLevel);

    return Column(
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
          _avatarLabels[energyLevel].split(' ').last,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: isSelected ? 12 : 10,
              color: isSelected ? color : Colors.grey[700],
            ),
          ),
        ),
      ],
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
    // Convert energy level to 0-100 scale where 2 (neutral) = 50
    final energyValue =
        _selectedEnergyLevel == 2
            ? 50.0
            : _selectedEnergyLevel < 2
            ? _selectedEnergyLevel *
                25.0 // 0-1 maps to 0-25
            : 50.0 + (_selectedEnergyLevel - 2) * 25.0; // 3-4 maps to 75-100

    setState(() {
      energyMetric.value = energyValue;
    });

    // Save energy value to Firebase
    _statsService.updateStat('energy', energyValue);
    print('💾 Saved energy value $energyValue to Firebase');
  }

  // Add chapter and update energy
  void _addChapter() {
    final readingMetric = _metrics.firstWhere((m) => m.title == 'Reading');
    final newReadingValue = (readingMetric.value + 1).clamp(
      0,
      readingMetric.maxValue,
    );

    if (newReadingValue != readingMetric.value) {
      final newEnergy = math.min(
        100,
        math.max(
          0,
          (_metrics.firstWhere((m) => m.title == 'Energy').value + 2),
        ),
      );
      _statsService.updateStats({
        'reading': newReadingValue,
        'energy': newEnergy,
      });
      setState(() {
        _selectedEnergyLevel = (newEnergy / 25).floor().clamp(0, 4);
      });
    }
  }

  // Add work hour and update energy
  void _addWorkHour() {
    final workMetric = _metrics.firstWhere((m) => m.title == 'Work');
    final newWorkValue = (workMetric.value + 1).clamp(0, workMetric.maxValue);

    if (newWorkValue != workMetric.value) {
      final newEnergy = math.min(
        100,
        math.max(
          0,
          (_metrics.firstWhere((m) => m.title == 'Energy').value + 2),
        ),
      );
      _statsService.updateStats({'work': newWorkValue, 'energy': newEnergy});
      setState(() {
        _selectedEnergyLevel = (newEnergy / 25).floor().clamp(0, 4);
      });
    }
  }

  // Add water glass and update energy
  void _addWater() {
    final waterMetric = _metrics.firstWhere((m) => m.title == 'Water');
    final newWaterValue = (waterMetric.value + 1).clamp(
      0,
      waterMetric.maxValue,
    );

    if (newWaterValue != waterMetric.value) {
      final newEnergy = math.min(
        100,
        math.max(
          0,
          (_metrics.firstWhere((m) => m.title == 'Energy').value + 2),
        ),
      );
      _statsService.updateStats({'water': newWaterValue, 'energy': newEnergy});
      setState(() {
        _selectedEnergyLevel = (newEnergy / 25).floor().clamp(0, 4);
      });
    }
  }

  // Update heart rate and adjust energy based on heart rate
  void _updateHeartRate(double change) {
    final heartMetric = _metrics.firstWhere((m) => m.title == 'Heart');
    final newHeartRate = (heartMetric.value + change).clamp(60, 200);

    if (newHeartRate != heartMetric.value) {
      final newEnergy = math.min(
        100,
        math.max(
          0,
          (_metrics.firstWhere((m) => m.title == 'Energy').value + 2),
        ),
      );
      _statsService.updateStats({'heart': newHeartRate, 'energy': newEnergy});
      setState(() {
        _selectedEnergyLevel = (newEnergy / 25).floor().clamp(0, 4);
      });
    }
  }

  // Update sleep hours and adjust energy based on sleep quality
  void _updateSleepHours(double change) {
    final sleepMetric = _metrics.firstWhere((m) => m.title == 'Sleep');
    final newSleepValue = (sleepMetric.value + change).clamp(
      0,
      sleepMetric.maxValue,
    );

    if (newSleepValue != sleepMetric.value) {
      final newEnergy = math.min(
        100,
        math.max(
          0,
          (_metrics.firstWhere((m) => m.title == 'Energy').value + 2),
        ),
      );
      _statsService.updateStats({'sleep': newSleepValue, 'energy': newEnergy});
      setState(() {
        _selectedEnergyLevel = (newEnergy / 25).floor().clamp(0, 4);
      });
    }
  }

  // Add calories and update energy
  void _addCalories(int amount) {
    final caloriesMetric = _metrics.firstWhere((m) => m.title == 'Calories');
    final newCalories = (caloriesMetric.value + amount).clamp(
      0,
      caloriesMetric.maxValue,
    );

    if (newCalories != caloriesMetric.value) {
      final newEnergy = math.min(
        100,
        math.max(
          0,
          (_metrics.firstWhere((m) => m.title == 'Energy').value + 2),
        ),
      );
      _statsService.updateStats({'calories': newCalories, 'energy': newEnergy});
      setState(() {
        _selectedEnergyLevel = (newEnergy / 25).floor().clamp(0, 4);
      });
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
      body: Stack(
        children: [
          // Main Content
          RefreshIndicator(
            onRefresh: () async {
              // Optionally fetch user info if available
              if (mounted &&
                  context.findAncestorStateOfType<_MainNavPageState>() !=
                      null) {
                await context
                    .findAncestorStateOfType<_MainNavPageState>()!
                    ._fetchAndStoreUserInfo();
              }
              await _loadDataFromFirebase();
            },
            child: SingleChildScrollView(
              controller: widget.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Color(0xFFF8F8F8), Colors.white],
                  ),
                ),
                child: Padding(
                  padding:
                      widget.immersiveMode
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 10.0,
                            bottom:
                                100.0, // Extra padding for the floating nav bar
                          ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!widget.immersiveMode) ...[
                        const SizedBox(height: 32),
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
                                  FutureBuilder<String>(
                                    future: SharedPreferences.getInstance()
                                        .then((prefs) {
                                          final userName = prefs.getString(
                                            'userName',
                                          );
                                          final avatarName =
                                              prefs.getString('avatarName') ??
                                              'Friend';
                                          return userName ?? avatarName;
                                        }),
                                    builder: (context, snapshot) {
                                      final fullName =
                                          snapshot.data ?? 'Friend';
                                      final firstName =
                                          fullName.split(' ').first;
                                      return Text(
                                        'Hi, $firstName',
                                        style: GoogleFonts.orbitron(
                                          textStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 2),
                                  // Welcome message (Nunito)
                                  Text(
                                    'Welcome to Augma Life',
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
                              // Settings button
                              Row(
                                children: [
                                  FloatingActionButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder:
                                              (
                                                context,
                                                animation,
                                                secondaryAnimation,
                                              ) => const SettingsPage(),
                                          transitionsBuilder: (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOutQuart;
                                            var tween = Tween(
                                              begin: begin,
                                              end: end,
                                            ).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation
                                                .drive(tween);
                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                          transitionDuration: const Duration(
                                            milliseconds: 500,
                                          ),
                                        ),
                                      );
                                    },
                                    backgroundColor: Colors.red[900],
                                    mini: true,
                                    elevation: 2,
                                    heroTag: 'settingsBtn',
                                    child: const Icon(
                                      Icons.settings,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      // Avatar section with time-of-day gradient
                      Card(
                        margin: widget.immersiveMode ? EdgeInsets.zero : null,
                        shape:
                            widget.immersiveMode
                                ? null
                                : RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                        child: Container(
                          height:
                              widget.immersiveMode
                                  ? MediaQuery.of(context).size.height * 0.725
                                  : null,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                            borderRadius:
                                widget.immersiveMode
                                    ? null
                                    : BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding:
                                widget.immersiveMode
                                    ? const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    )
                                    : const EdgeInsets.symmetric(
                                      horizontal: 14.0,
                                      vertical: 10.0,
                                    ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment:
                                  widget.immersiveMode
                                      ? MainAxisAlignment.spaceEvenly
                                      : MainAxisAlignment.start,
                              children: [
                                if (widget.immersiveMode)
                                  const SizedBox(height: 40),
                                // Date (Nunito)
                                const SizedBox(height: 1),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Title (Orbitron)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        FutureBuilder<String>(
                                          future:
                                              SharedPreferences.getInstance()
                                                  .then(
                                                    (prefs) =>
                                                        prefs.getString(
                                                          'userName',
                                                        ) ??
                                                        'Friend',
                                                  ),
                                          builder: (context, snapshot) {
                                            final userName =
                                                snapshot.data ?? 'Friend';
                                            return Text(
                                              widget.immersiveMode
                                                  ? 'Hello, $userName'
                                                  : userName,
                                              style: GoogleFonts.orbitron(
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        if (widget.immersiveMode)
                                          Text(
                                            'Welcome to Augma Aura',
                                            style: GoogleFonts.nunito(
                                              textStyle: TextStyle(
                                                fontSize: 16,
                                                color: Colors.red[900],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                    _getCelestialIcon(),
                                  ],
                                ),
                                //const SizedBox(height: 2),

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
                                        child: Builder(
                                          builder: (context) {
                                            final energy =
                                                _metrics
                                                    .firstWhere(
                                                      (m) =>
                                                          m.title == 'Energy',
                                                    )
                                                    .value;
                                            final auraLevel = (energy / 25)
                                                .floor()
                                                .clamp(0, 4);
                                            return LinearProgressIndicator(
                                              value: energy / 100.0,
                                              minHeight: 8,
                                              backgroundColor: Colors.white24,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    _getColorForEnergyLevel(
                                                      auraLevel,
                                                    ),
                                                  ),
                                            );
                                          },
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
                                        '${_metrics.firstWhere((m) => m.title == 'Energy').value.toInt()}',
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
                                  height:
                                      screenWidth * 0.5, // Even smaller height
                                  width:
                                      screenWidth *
                                      0.45, // Slightly smaller width
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
                                Column(
                                  children: [
                                    FutureBuilder<String>(
                                      future: FirebaseService()
                                          .getUserProfile(
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid,
                                          )
                                          .then(
                                            (profile) =>
                                                profile?['avatarName'] ??
                                                'Friend',
                                          ),
                                      builder: (context, snapshot) {
                                        final avatarName =
                                            snapshot.data ?? 'Friend';
                                        return Text(
                                          "$avatarName Energy: ${_avatarLabels[_selectedEnergyLevel].toLowerCase()}",
                                          style: GoogleFonts.nunito(
                                            textStyle: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    widget.immersiveMode
                                        ? const SizedBox(height: 0)
                                        : const SizedBox(height: 6),
                                    // Based on metrics (Nunito)
                                    // Text(
                                    //   "Avatar energy: ${_avatarLabels[_selectedEnergyLevel].toLowerCase()}",
                                    //   style: GoogleFonts.nunito(
                                    //     textStyle: const TextStyle(
                                    //       fontSize: 20,
                                    //       fontWeight: FontWeight.bold,
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(height: 2),
                                    // Based on metrics (Nunito)
                                    Text(
                                      "Reflection of your energy",
                                      style: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Insight label (Orbitron)
                                          Text(
                                            "Insight:",
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
                                                _currentMantra =
                                                    _getRandomMantra();
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                          padding: EdgeInsets.all(
                            widget.immersiveMode ? 16 : 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Emotion question (Orbitron)
                                  Text(
                                    'Your Aura Today',
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
                              // Emotion buttons row - now non-interactive
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: List.generate(5, (index) {
                                    final energy =
                                        _metrics
                                            .firstWhere(
                                              (m) => m.title == 'Energy',
                                            )
                                            .value;
                                    final auraLevel = (energy / 25)
                                        .floor()
                                        .clamp(0, 4);
                                    final isSelected = auraLevel == index;
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? _getColorForEnergyLevel(
                                                        index,
                                                      )
                                                      : Colors.grey[300]!,
                                              width: 2,
                                            ),
                                            boxShadow:
                                                isSelected
                                                    ? [
                                                      BoxShadow(
                                                        color:
                                                            _getColorForEnergyLevel(
                                                              index,
                                                            ).withOpacity(0.3),
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
                                                color:
                                                    isSelected
                                                        ? _getColorForEnergyLevel(
                                                          index,
                                                        )
                                                        : _getColorForEnergyLevel(
                                                          index,
                                                        ).withOpacity(0.2),
                                                shape: BoxShape.circle,
                                                boxShadow:
                                                    isSelected
                                                        ? [
                                                          BoxShadow(
                                                            color:
                                                                _getColorForEnergyLevel(
                                                                  index,
                                                                ).withOpacity(
                                                                  0.3,
                                                                ),
                                                            spreadRadius: 1,
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  0,
                                                                ),
                                                          ),
                                                        ]
                                                        : [],
                                              ),
                                              child: Icon(
                                                _emotionIcons[index],
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : Colors.grey[600],
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _avatarLabels[index].split(' ').last,
                                          style: GoogleFonts.nunito(
                                            textStyle: TextStyle(
                                              fontWeight:
                                                  isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                              fontSize: isSelected ? 12 : 10,
                                              color:
                                                  isSelected
                                                      ? _getColorForEnergyLevel(
                                                        index,
                                                      )
                                                      : Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Intentions section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Daily Intentions',
                                    style: GoogleFonts.orbitron(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.amber[700],
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  children: [
                                    for (int i = 0; i < _intentions.length; i++)
                                      _buildIntentionItem(i),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  'Complete intentions to gain +10% energy each',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                      Icon(
                                        Icons.work,
                                        color: Colors.brown,
                                        size: 20,
                                      ),
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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

                      const SizedBox(height: 24),

                      // Gratitude Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Daily Gratitude',
                                    style: GoogleFonts.orbitron(
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
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
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  children: [
                                    // Gratitude entries list
                                    StreamBuilder<List<Map<String, dynamic>>>(
                                      stream:
                                          _statsService.getGratitudeStream(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final gratitudeList = snapshot.data!;
                                          if (gratitudeList.isEmpty) {
                                            return Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(
                                                  'Add things you\'re grateful for today',
                                                  style: GoogleFonts.nunito(
                                                    color: Colors.grey[600],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                          return Column(
                                            children:
                                                gratitudeList.map((entry) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 8.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.favorite,
                                                          color:
                                                              Colors.red[900],
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            entry['text']
                                                                as String,
                                                            style: GoogleFonts.nunito(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors
                                                                      .black87,
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color:
                                                                Colors
                                                                    .grey[600],
                                                            size: 18,
                                                          ),
                                                          onPressed: () {
                                                            _statsService
                                                                .deleteGratitudeEntry(
                                                                  entry['id'],
                                                                );
                                                          },
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                          );
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Add Gratitude button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _showAddGratitudeDialog();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    'Add Gratitude',
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[900],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SettingsPage(),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.easeInOutQuart;
                                var tween = Tween(
                                  begin: begin,
                                  end: end,
                                ).chain(CurveTween(curve: curve));
                                var offsetAnimation = animation.drive(tween);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(
                                milliseconds: 500,
                              ),
                            ),
                          );
                        },
                        backgroundColor: Colors.red[900],
                        mini: true,
                        elevation: 2,
                        heroTag: 'settingsBtn',
                        child: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog to add gratitude entry
  void _showAddGratitudeDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Add Gratitude',
              style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'What are you grateful for today?',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    _statsService.addGratitudeEntry(controller.text.trim());
                    // Add 5 energy points for gratitude
                    final newEnergy = math.min(
                      100,
                      math.max(
                        0,
                        (_metrics.firstWhere((m) => m.title == 'Energy').value +
                            5),
                      ),
                    );
                    _statsService.updateStats({'energy': newEnergy});
                    setState(() {
                      _selectedEnergyLevel = (newEnergy / 25).floor().clamp(
                        0,
                        4,
                      );
                    });
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                ),
                child: Text('Add', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  // Build intention item widget
  Widget _buildIntentionItem(int index) {
    final intention = _intentions[index];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Checkbox
          Checkbox(
            value: intention.isCompleted,
            onChanged: (_) => _toggleIntention(index),
            activeColor: Colors.red[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          // Intention text
          Expanded(
            child: Text(
              intention.text,
              style: GoogleFonts.nunito(
                decoration:
                    intention.isCompleted ? TextDecoration.lineThrough : null,
                color: intention.isCompleted ? Colors.grey : Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          // Edit button
          IconButton(
            icon: Icon(Icons.edit, size: 18, color: Colors.grey[600]),
            onPressed: () => _editIntention(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _healthSyncEnabled = true;
  bool _isMetric = true;
  bool _immersiveMode = false;
  late SharedPreferences _prefs;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = _prefs.getBool('notifications') ?? true;
      _healthSyncEnabled = _prefs.getBool('healthSync') ?? true;
      _isMetric = _prefs.getBool('isMetric') ?? true;
      _immersiveMode = _prefs.getBool('immersiveMode') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    await _prefs.setBool('notifications', _notificationsEnabled);
    await _prefs.setBool('healthSync', _healthSyncEnabled);
    await _prefs.setBool('isMetric', _isMetric);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved successfully',
          style: GoogleFonts.nunito(),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(
              'Sign Out',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to sign out?',
              style: GoogleFonts.nunito(color: Colors.grey[300]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.orbitron(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'SIGN OUT',
                  style: GoogleFonts.orbitron(
                    color: Colors.red[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/welcome',
            (route) => false,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: e.toString()}'),
            backgroundColor: Colors.red[900],
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setImmersiveMode(bool value) async {
    setState(() => _immersiveMode = value);
    await _prefs.setBool('immersiveMode', value);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'SETTINGS',
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Settings List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section
                        SettingsSection(
                          title: 'PROFILE',
                          children: [
                            SettingsTile(
                              title: 'Edit Profile',
                              subtitle: 'Change your personal information',
                              icon: Icons.person_outline,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const EditProfilePage(),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            SettingsTile(
                              title: 'Change Password',
                              subtitle: 'Update your security credentials',
                              icon: Icons.lock_outline,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const ChangePasswordPage(),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Preferences Section
                        SettingsSection(
                          title: 'PREFERENCES',
                          children: [
                            SettingsSwitch(
                              title: 'Notifications',
                              subtitle:
                                  'Receive important updates and reminders',
                              icon: Icons.notifications_outlined,
                              value: _notificationsEnabled,
                              onChanged:
                                  (value) => setState(
                                    () => _notificationsEnabled = value,
                                  ),
                            ),
                            SettingsSwitch(
                              title: 'Immersive Mode',
                              subtitle:
                                  'Hide greeting and settings icon, expand avatar',
                              icon: Icons.fullscreen,
                              value: _immersiveMode,
                              onChanged: (value) => _setImmersiveMode(value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Health & Data Section
                        SettingsSection(
                          title: 'HEALTH & DATA',
                          children: [
                            SettingsSwitch(
                              title: 'Health Sync',
                              subtitle: 'Sync with Apple Health or Google Fit',
                              icon: Icons.favorite_border,
                              value: _healthSyncEnabled,
                              onChanged:
                                  (value) => setState(
                                    () => _healthSyncEnabled = value,
                                  ),
                            ),
                            SettingsSwitch(
                              title: 'Metric Units',
                              subtitle: 'Use metric system for measurements',
                              icon: Icons.straighten,
                              value: _isMetric,
                              onChanged:
                                  (value) => setState(() => _isMetric = value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // System Section
                        SettingsSection(
                          title: 'SYSTEM',
                          children: [
                            SettingsTile(
                              title: 'About',
                              subtitle: 'App version and information',
                              icon: Icons.info_outline,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const AboutPage(),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            SettingsTile(
                              title: 'Debug',
                              subtitle: 'App debug and diagnostics',
                              icon: Icons.bug_report,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => const DebugPage(),
                                    transitionsBuilder: (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            SettingsTile(
                              title: 'Logout',
                              subtitle: 'Sign out of your account',
                              icon: Icons.logout,
                              onTap: _showLogoutDialog,
                              isDestructive: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Test Notification Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () async {
                              final tz.TZDateTime scheduledDate = tz
                                  .TZDateTime.now(
                                tz.local,
                              ).add(const Duration(seconds: 10));
                              await flutterLocalNotificationsPlugin.zonedSchedule(
                                999, // Unique ID for test
                                'Test Notification',
                                'This is a test notification from Augma Aura.',
                                scheduledDate,
                                const NotificationDetails(
                                  android: AndroidNotificationDetails(
                                    'test_channel',
                                    'Test Notifications',
                                    channelDescription:
                                        'Channel for test notifications',
                                    importance: Importance.max,
                                    priority: Priority.high,
                                  ),
                                  iOS: DarwinNotificationDetails(),
                                ),
                                androidAllowWhileIdle: true,
                                uiLocalNotificationDateInterpretation:
                                    UILocalNotificationDateInterpretation
                                        .absoluteTime,
                                matchDateTimeComponents:
                                    DateTimeComponents.time,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[900],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.red[900]?.withOpacity(0.5),
                            ),
                            child: Text(
                              'TEST NOTIFICATION',
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Save Button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DailyGoalPage extends StatefulWidget {
  final ScrollController? scrollController;
  const DailyGoalPage({super.key, this.scrollController});

  @override
  State<DailyGoalPage> createState() => _DailyGoalPageState();
}

class _DailyGoalPageState extends State<DailyGoalPage> {
  final Map<String, int> _metricGoals = {
    'Water': 6,
    'Sleep': 7,
    'Work': 5,
    'Reading': 3,
    'Calories': 800,
    'Heart': 70,
  };

  final List<String> _emotions = [
    'Super Exhausted',
    'Tired',
    'Neutral',
    'Happy',
    'Super Happy',
  ];

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _updateGoalInFirebase(String key, int value) async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      await _firebaseService.updateUserProfile(user.uid, {'goal_$key': value});
    }
  }

  Future<void> _updateTotalEnergyInFirebase() async {
    final user = _firebaseService.currentUser;
    if (user != null) {
      // Example: sum all goals for demo, you should use your real energy calculation
      int total = _metricGoals.values.fold(0, (a, b) => a + b);
      int energy =
          (total / (_metricGoals.length * 10) * 100).clamp(0, 100).toInt();
      await _firebaseService.updateUserProfile(user.uid, {'energy': energy});
    }
  }

  void _incrementGoal(String key) {
    setState(() {
      _metricGoals[key] = (_metricGoals[key] ?? 0) + 1;
    });
    _updateGoalInFirebase(key, _metricGoals[key]!);
    _updateTotalEnergyInFirebase();
  }

  void _decrementGoal(String key) {
    setState(() {
      if ((_metricGoals[key] ?? 0) > 0) {
        _metricGoals[key] = (_metricGoals[key] ?? 0) - 1;
      }
    });
    _updateGoalInFirebase(key, _metricGoals[key]!);
    _updateTotalEnergyInFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set your daily goals',
                style: GoogleFonts.orbitron(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: widget.scrollController,
                  children:
                      _metricGoals.entries.map((entry) {
                        final icon = () {
                          switch (entry.key) {
                            case 'Water':
                              return Icons.water_drop;
                            case 'Sleep':
                              return Icons.nightlight_round;
                            case 'Work':
                              return Icons.work_outline;
                            case 'Reading':
                              return Icons.menu_book_outlined;
                            case 'Calories':
                              return Icons.local_fire_department;
                            case 'Heart':
                              return Icons.favorite_border;
                            default:
                              return Icons.flag;
                          }
                        }();
                        return Card(
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      icon,
                                      color: Colors.red[900],
                                      size: 28,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      entry.key,
                                      style: GoogleFonts.orbitron(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      color: Colors.red[900],
                                      onPressed:
                                          () => _decrementGoal(entry.key),
                                    ),
                                    Container(
                                      width: 32,
                                      alignment: Alignment.center,
                                      child: Text(
                                        (_metricGoals[entry.key] ?? 0)
                                            .toString(),
                                        style: GoogleFonts.orbitron(
                                          fontSize: 18,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      color: Colors.red[900],
                                      onPressed:
                                          () => _incrementGoal(entry.key),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Save goals and baseline to Firebase or SharedPreferences here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Goals saved!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'Save Goals',
                    style: GoogleFonts.orbitron(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add this function to show the reset dialog
void showResetDataDialog(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.red[900]!.withOpacity(0.3),
              width: 1,
            ),
          ),
          title: Text(
            'Reset Today\'s Data',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all data for today? This action cannot be undone.',
            style: GoogleFonts.nunito(color: Colors.grey[400], fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: GoogleFonts.orbitron(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // Reset Firebase data
                  final statsService = StatsService();
                  await statsService.resetDailyStats();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Today\'s data has been reset',
                        style: GoogleFonts.nunito(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error resetting data: ${e.toString()}',
                        style: GoogleFonts.nunito(),
                      ),
                      backgroundColor: Colors.red[900],
                    ),
                  );
                }
              },
              child: Text(
                'RESET',
                style: GoogleFonts.orbitron(
                  color: Colors.red[900],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
  );
}
