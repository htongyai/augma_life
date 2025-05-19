import 'package:flutter/material.dart';

class RabbitAvatarPng extends StatelessWidget {
  final int energyLevel;

  const RabbitAvatarPng({super.key, required this.energyLevel});

  @override
  Widget build(BuildContext context) {
    // Get the appropriate image based on energy level
    String imagePath = _getImagePathForEnergyLevel();

    return FractionallySizedBox(
      widthFactor: 1.1, // Make image 10% bigger
      heightFactor: 1.1,
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }

  // Determine which image file to use based on energy level
  String _getImagePathForEnergyLevel() {
    switch (energyLevel) {
      case 0: // Super exhausted
        return 'assets/avatar/bune_stage1.png';
      case 1: // Tired
        return 'assets/avatar/bune_stage2.png';
      case 2: // Neutral
        return 'assets/avatar/bune_stage3.png';
      case 3: // Happy
        return 'assets/avatar/bune_stage4.png'; // Fallback to stage3 for now
      case 4: // Super happy
        return 'assets/avatar/bune_stage5.png'; // Fallback to stage3 for now
      default:
        return 'assets/avatar/bune_stage3.png'; // Default to neutral
    }
  }

  // Color method kept for potential future use
  Color _getColorForEnergyLevel(int level) {
    switch (level) {
      case 0:
        return Colors.red[700]!; // Super exhausted
      case 1:
        return Colors.orange[600]!; // Tired
      case 2:
        return Colors.yellow[600]!; // Neutral
      case 3:
        return Colors.lightGreen[600]!; // Happy
      case 4:
        return Colors.green[600]!; // Super happy
      default:
        return Colors.yellow[600]!; // Default to neutral
    }
  }
}
