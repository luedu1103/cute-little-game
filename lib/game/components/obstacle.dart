import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class Obstacle extends PositionComponent with CollisionCallbacks {
  final bool moveLeft;
  final bool falling;
  final double speed = 200;

  late final SpriteAnimationComponent _animation;

  Obstacle({
    required Vector2 position,
    required this.moveLeft,
    this.falling = false,
  }) {
    this.position = position;
    size = falling ? Vector2(45, 90) : Vector2(70, 70);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    final spriteName = falling
        ? 'new-meteorite-Sheet.png'
        : 'redDragon-Sheet.png';
    final image = await Flame.images.load(spriteName);

    final animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: falling ? 4 : 8,
        stepTime: 0.1,
        textureSize: falling ? Vector2(32, 64) : Vector2(32, 32),
      ),
    );

    _animation = SpriteAnimationComponent(animation: animation, size: size);

    if (!falling && !moveLeft) {
      _animation.flipHorizontallyAroundCenter();
    }

    add(_animation);

    final hitboxSize = size * 0.5;
    final hitboxOffset = size * 0.25;
    add(RectangleHitbox(size: hitboxSize, position: hitboxOffset));
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
}
