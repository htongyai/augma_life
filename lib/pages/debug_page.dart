import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  Future<void> _testNotification(BuildContext context) async {
    await flutterLocalNotificationsPlugin.show(
      9999,
      'Test Notification',
      'This is a test notification from DebugPage.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Channel for debug/test notifications',
        ),
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Debug Tools',
          style: GoogleFonts.orbitron(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Debug Features',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => _testNotification(context),
                icon: const Icon(Icons.notifications_active),
                label: const Text('Test Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
