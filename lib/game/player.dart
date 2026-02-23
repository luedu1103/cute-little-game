import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'obstacle.dart';

class Player extends PositionComponent with CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  final double gravity = 900;
  final double jumpForce = -450;

  late Function onGameOver;

  Player({required this.onGameOver}) {
    size = Vector2.all(32);
    position = Vector2(200, 600);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    velocity.y += gravity * dt;
    position += velocity * dt;
    position.x = position.x.clamp(size.x / 2, findGame()!.size.x - size.x / 2);
  }

  void jump(double directionX) {
    velocity.y = jumpForce;
    velocity.x = 150 * directionX;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Body
    final paint = Paint()..color = Colors.pinkAccent;
    canvas.drawRect(size.toRect(), paint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(10, 12), 4, eyePaint);
    canvas.drawCircle(Offset(22, 12), 4, eyePaint);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle) {
      onGameOver();
    }
    super.onCollision(intersectionPoints, other);
  }
}
