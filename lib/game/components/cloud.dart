import 'package:flame/components.dart';
import 'package:flutter/material.dart'; 

class CloudComponent extends PositionComponent {
  final double speed;
  final String spriteName;

  CloudComponent({
    required Vector2 position,
    required Vector2 size,
    required this.speed,
    required this.spriteName,
  }) {
    this.position = position;
    this.size = size;
    anchor = Anchor.center;
    priority = -10;
  }

  @override
Future<void> onLoad() async {
  final sprite = await Sprite.load(spriteName);

  final spriteComponent = SpriteComponent(
    sprite: sprite,
    size: size,
    paint: Paint()
        ..colorFilter = ColorFilter.mode(
            const Color(0xFFBFE9FF).withOpacity(0.5), // tinte cielo
            BlendMode.srcATop,
        ),
    );

  add(spriteComponent);
}

  @override
  void update(double dt) {
    super.update(dt);
    position.x += speed * dt;

    if (position.x < -300 || position.x > 2200) {
      removeFromParent();
    }
  }
}
