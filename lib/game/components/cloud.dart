import 'package:flame/components.dart';

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
    add(SpriteComponent(sprite: sprite, size: size));
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
