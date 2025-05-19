import 'package:flutter/material.dart';
import 'dart:math' as math;

class RabbitAvatar extends StatelessWidget {
  final int energyLevel;

  const RabbitAvatar({super.key, required this.energyLevel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(painter: RabbitPainter(energyLevel: energyLevel)),
    );
  }
}

class RabbitPainter extends CustomPainter {
  final int energyLevel;

  RabbitPainter({required this.energyLevel});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);

    // Define colors based on energy level
    final Color baseColor = _getColorForEnergyLevel(energyLevel);
    final Color darkColor = baseColor.darker();
    final Color lightColor = baseColor.lighter();

    final paint =
        Paint()
          ..color = baseColor
          ..style = PaintingStyle.fill;

    // Body
    final bodyRadius = width * 0.35;
    canvas.drawCircle(
      Offset(center.dx, center.dy + height * 0.05),
      bodyRadius,
      paint,
    );

    // Head
    final headRadius = width * 0.25;
    canvas.drawCircle(
      Offset(center.dx, center.dy - height * 0.15),
      headRadius,
      paint,
    );

    // Ears
    final earPaint =
        Paint()
          ..color = lightColor
          ..style = PaintingStyle.fill;

    // Left ear
    _drawEar(
      canvas,
      Offset(center.dx - width * 0.15, center.dy - height * 0.30),
      width * 0.12,
      height * 0.25,
      -math.pi / 6,
      earPaint,
    );

    // Right ear
    _drawEar(
      canvas,
      Offset(center.dx + width * 0.15, center.dy - height * 0.30),
      width * 0.12,
      height * 0.25,
      math.pi / 6,
      earPaint,
    );

    // Face features
    _drawFace(canvas, size, center, energyLevel, darkColor);
  }

  void _drawEar(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double angle,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );

    final roundedRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(width / 2),
    );

    canvas.drawRRect(roundedRect, paint);
    canvas.restore();
  }

  void _drawFace(
    Canvas canvas,
    Size size,
    Offset center,
    int energyLevel,
    Color darkColor,
  ) {
    final eyePaint =
        Paint()
          ..color = darkColor
          ..style = PaintingStyle.fill;

    final nosePaint =
        Paint()
          ..color = Colors.pink[100]!
          ..style = PaintingStyle.fill;

    // Eyes
    final eyeRadius = size.width * 0.04;
    final eyeY = center.dy - size.height * 0.15;
    final eyeSpacing = size.width * 0.12;

    canvas.drawCircle(
      Offset(center.dx - eyeSpacing, eyeY),
      eyeRadius,
      eyePaint,
    );

    canvas.drawCircle(
      Offset(center.dx + eyeSpacing, eyeY),
      eyeRadius,
      eyePaint,
    );

    // Nose
    final noseY = eyeY + size.height * 0.08;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, noseY),
        width: size.width * 0.08,
        height: size.height * 0.04,
      ),
      nosePaint,
    );

    // Mouth - changes based on energy level
    _drawMouth(canvas, size, center, energyLevel, darkColor);
  }

  void _drawMouth(
    Canvas canvas,
    Size size,
    Offset center,
    int energyLevel,
    Color darkColor,
  ) {
    final mouthPaint =
        Paint()
          ..color = darkColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final mouthY = center.dy - size.height * 0.05;
    final mouthWidth = size.width * 0.2;

    // Different mouth shapes based on energy level
    switch (energyLevel) {
      case 0: // Super exhausted - frown
        final rect = Rect.fromCenter(
          center: Offset(center.dx, mouthY + size.height * 0.05),
          width: mouthWidth,
          height: size.height * 0.1,
        );
        canvas.drawArc(rect, math.pi * 0.8, math.pi * 0.4, false, mouthPaint);
        break;

      case 1: // Tired - slight frown
        final rect = Rect.fromCenter(
          center: Offset(center.dx, mouthY + size.height * 0.03),
          width: mouthWidth,
          height: size.height * 0.06,
        );
        canvas.drawArc(rect, math.pi * 0.8, math.pi * 0.4, false, mouthPaint);
        break;

      case 2: // Neutral - straight line
        canvas.drawLine(
          Offset(center.dx - mouthWidth / 2, mouthY),
          Offset(center.dx + mouthWidth / 2, mouthY),
          mouthPaint,
        );
        break;

      case 3: // Happy - slight smile
        final rect = Rect.fromCenter(
          center: Offset(center.dx, mouthY - size.height * 0.03),
          width: mouthWidth,
          height: size.height * 0.06,
        );
        canvas.drawArc(rect, math.pi * 0.2, math.pi * 0.6, false, mouthPaint);
        break;

      case 4: // Super Happy - big smile
        final rect = Rect.fromCenter(
          center: Offset(center.dx, mouthY - size.height * 0.05),
          width: mouthWidth,
          height: size.height * 0.1,
        );
        canvas.drawArc(rect, math.pi * 0.2, math.pi * 0.6, false, mouthPaint);
        break;
    }
  }

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

  @override
  bool shouldRepaint(RabbitPainter oldDelegate) =>
      oldDelegate.energyLevel != energyLevel;
}

extension ColorExtension on Color {
  Color darker() {
    return Color.fromARGB(
      alpha,
      (red * 0.7).round(),
      (green * 0.7).round(),
      (blue * 0.7).round(),
    );
  }

  Color lighter() {
    return Color.fromARGB(
      alpha,
      red + ((255 - red) * 0.3).round(),
      green + ((255 - green) * 0.3).round(),
      blue + ((255 - blue) * 0.3).round(),
    );
  }
}
