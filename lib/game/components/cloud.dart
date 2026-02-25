import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Cloud {
  Vector2 position;
  Vector2 size;
  double speed;
  double currentOpacity;

  Cloud({
    required this.position,
    required this.size,
    required this.speed,
    required double opacity,
  }) : currentOpacity = opacity;

  /// Offsets (fracción del ancho) y radios (fracción del ancho) de cada puff
  static const List<(double, double, double)> _puffs = [
    (0.00, 0.55, 0.30), // base izquierda
    (0.25, 0.30, 0.38), // centro alto
    (0.55, 0.50, 0.28), // base derecha
    (0.72, 0.25, 0.25), // cima derecha
    (-0.05, 0.25, 0.25), // cima izquierda
  ];

  void render(Canvas canvas) {
    if (currentOpacity <= 0) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(currentOpacity.clamp(0.0, 1.0));

    for (final (fx, fy, fr) in _puffs) {
      canvas.drawCircle(Offset(size.x * fx, size.y * fy), size.x * fr, paint);
    }
  }
}
