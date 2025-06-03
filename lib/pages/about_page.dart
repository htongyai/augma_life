import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
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
                      'ABOUT',
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

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Logo and Name
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.red[900],
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red[900]!.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Image.asset(
                                  'assets/lifelogo.png',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'AUGMA AURA',
                              style: GoogleFonts.orbitron(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Version $_version',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Description
                      Text(
                        'About Augma Aura',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Augma Aura is a wellness app designed to help you track and improve your daily energy levels, set intentions, and practice gratitude. By monitoring your daily activities and emotions, you can better understand your energy patterns and make positive changes in your life.',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey[300],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Features
                      Text(
                        'Key Features',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: Icons.energy_savings_leaf,
                        title: 'Energy Tracking',
                        description:
                            'Monitor your daily energy levels and understand your patterns.',
                      ),
                      _buildFeatureItem(
                        icon: Icons.check_circle_outline,
                        title: 'Daily Intentions',
                        description:
                            'Set and track your daily intentions for personal growth.',
                      ),
                      _buildFeatureItem(
                        icon: Icons.favorite,
                        title: 'Gratitude Journal',
                        description:
                            'Practice gratitude by recording what you\'re thankful for.',
                      ),
                      _buildFeatureItem(
                        icon: Icons.insights,
                        title: 'Wellness Metrics',
                        description:
                            'Track sleep, water intake, work, and exercise to improve your wellbeing.',
                      ),
                      const SizedBox(height: 32),

                      // Credits
                      Text(
                        'Credits',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Developed by Augma Imaginarium\n\n'
                        '© ${DateTime.now().year} All rights reserved.',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[900]!.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.red[900], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
