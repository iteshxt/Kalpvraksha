import 'dart:math' as Math;
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color waveColor;
  final double lineWidth;

  WaveformPainter({
    required this.amplitudes,
    this.waveColor = Colors.blue,
    this.lineWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;
    final stepX = size.width / (amplitudes.length - 1);

    // Create a smooth waveform path
    final path = Path();
    bool isFirst = true;

    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * stepX;
      final amplitude = amplitudes[i] * midY * 0.8; // Scale to 80% of available height
      final y = midY + amplitude * (i % 2 == 0 ? -1 : 1); // Alternate positive/negative

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw individual amplitude bars for more visual appeal
    final barPaint = Paint()
      ..color = waveColor.withOpacity(0.6)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * stepX;
      final amplitude = amplitudes[i] * midY * 0.9;
      
      canvas.drawLine(
        Offset(x, midY - amplitude),
        Offset(x, midY + amplitude),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
           oldDelegate.waveColor != waveColor ||
           oldDelegate.lineWidth != lineWidth;
  }
}

class CircularWaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color waveColor;
  final double lineWidth;
  final double radius;

  CircularWaveformPainter({
    required this.amplitudes,
    this.waveColor = Colors.blue,
    this.lineWidth = 2.0,
    this.radius = 50.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw circular waveform
    for (int i = 0; i < amplitudes.length; i++) {
      final angle = (i / amplitudes.length) * 2 * 3.14159; // Full circle
      final amplitude = amplitudes[i] * 20; // Scale amplitude
      
      final innerRadius = radius - amplitude;
      final outerRadius = radius + amplitude;
      
      final innerX = center.dx + innerRadius * Math.cos(angle);
      final innerY = center.dy + innerRadius * Math.sin(angle);
      final outerX = center.dx + outerRadius * Math.cos(angle);
      final outerY = center.dy + outerRadius * Math.sin(angle);
      
      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularWaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
           oldDelegate.waveColor != waveColor ||
           oldDelegate.lineWidth != lineWidth ||
           oldDelegate.radius != radius;
  }
}
