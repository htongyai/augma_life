import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              value
                  ? Colors.red[900]!.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    value
                        ? Colors.red[900]!.withOpacity(0.2)
                        : Colors.red[900]!.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.red[900], size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.red[900],
              activeTrackColor: Colors.red[900]!.withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[800],
            ),
          ],
        ),
      ),
    );
  }
}
