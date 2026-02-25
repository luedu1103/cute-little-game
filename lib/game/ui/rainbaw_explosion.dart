import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RainbowRay {
  double length = 0;
  final double maxLength;
  final double width;
  final Color color;
  final double lifeSpeed;
  double life = 1.0;

  final double dirX;
  final double dirY;

  RainbowRay({
    required double angle,
    required this.maxLength,
    required this.width,
    required this.color,
    required this.lifeSpeed,
  }) : dirX = cos(angle),
       dirY = sin(angle);
}

class RainbowExplosion extends PositionComponent {
  final VoidCallback onFinished;
  final Vector2 gameSize;

  final List<RainbowRay> _rays = [];

  static const List<Color> _rainbowColors = [
    Color(0xFFFF0000),
    Color(0xFFFF6600),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00CCFF),
    Color(0xFF8800FF),
    Color(0xFFFF00CC),
    Color(0xFFFFFFFF),
  ];

  bool _finished = false;
  late final Paint _paint;

  double _rotation = 0;
  double _angularVelocity = 0.5; // velocidad inicial
  double _angularAcceleration = 6.0; // aceleración progresiva

  RainbowExplosion({
    required Vector2 explosionPosition,
    required this.gameSize,
    required this.onFinished,
  }) {
    position = explosionPosition;
    anchor = Anchor.center;
    priority = 200;
  }

  @override
  Future<void> onLoad() async {
    const rayCount = 20;
    final maxRadius = gameSize.length;

    _paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * pi * 2;

      _rays.add(
        RainbowRay(
          angle: angle,
          maxLength: maxRadius,
          width: 10,
          color: _rainbowColors[i % _rainbowColors.length],
          lifeSpeed: 0.4,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool allDead = true;

    _angularVelocity += _angularAcceleration * dt;
    _rotation += _angularVelocity * dt;

    for (final ray in _rays) {
      if (ray.life <= 0) continue;

      allDead = false;

      ray.life -= ray.lifeSpeed * dt;
      ray.length = ray.maxLength * (1 - ray.life);
    }

    if (allDead && !_finished) {
      _finished = true;
      onFinished();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(_rotation);

    for (int i = 0; i < _rays.length; i++) {
      final ray = _rays[i];
      if (ray.life <= 0) continue;

      final progress = 1 - ray.life;

      final sweepAngle = (2 * pi) / _rays.length;

      final radius = ray.maxLength * progress;

      final rect = Rect.fromCircle(center: Offset.zero, radius: radius);

      _paint
        ..color = ray.color.withOpacity(ray.life)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        rect,
        i * sweepAngle,
        sweepAngle,
        true, // usa centro → forma de cono
        _paint,
      );
    }

    canvas.restore();
  }
}
