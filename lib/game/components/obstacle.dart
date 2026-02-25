import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent with CollisionCallbacks {
  final bool moveLeft;
  final bool falling;
  final double speed = 200;

  Obstacle({
    required Vector2 position,
    required this.moveLeft,
    this.falling = false,
  }) {
    this.position = position;
    size = Vector2(40, 20);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (falling) {
      position.y += speed * dt;
    } else {
      position.x += (moveLeft ? -1 : 1) * speed * dt;
    }

    if (position.x < -200 || position.x > 2000 || position.y > 3000) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = falling
          ? const Color(0xFFFFA500) // naranja si cae
          : const Color(0xFF6C63FF); // morado si lateral

    canvas.drawRect(size.toRect(), paint);
  }
}
