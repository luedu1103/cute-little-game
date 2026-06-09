import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'obstacle.dart';

class Player extends PositionComponent with CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  final double gravity = 900;
  final double jumpForce = -450;

  bool isVisible = true;
  late Function onGameOver;
  late Function onDeathSpinComplete;

  late final SpriteComponent _sprite;
  double _rotationDirection = 0;

  bool _isDying = false;
  double _deathTimer = 0;
  static const double _deathSpinDuration = 1.2;
  double _deathSpinSpeed = 3.0;

  Player({required this.onGameOver, required this.onDeathSpinComplete}) {
    size = Vector2.all(48);
    position = Vector2(200, 600);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    debugMode = false;
    _sprite = SpriteComponent(
      sprite: await Sprite.load('player.png'),
      size: size,
    );
    add(_sprite);

    final hitboxSize = size * 0.6;
    final hitboxOffset = size * 0.2;
    add(RectangleHitbox(size: hitboxSize, position: hitboxOffset));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isVisible) return;

    if (_isDying) {
      _deathTimer += dt;
      _deathSpinSpeed += 20.0 * dt;
      angle += _deathSpinSpeed * dt;

      final progress = (_deathTimer / _deathSpinDuration).clamp(0.0, 1.0);
      scale = Vector2.all(1.0 - progress * 0.3);

      if (_deathTimer >= _deathSpinDuration) {
        isVisible = false;
        _sprite.removeFromParent();
        onDeathSpinComplete();
      }
      return;
    }

    velocity.y += gravity * dt;
    position += velocity * dt;
    position.x = position.x.clamp(size.x / 2, findGame()!.size.x - size.x / 2);

    if (position.y < 0) {
      position.y = 0;
      velocity.y = 0;
    }

    angle += _rotationDirection * 5.0 * dt;
  }

  void jump(double directionX) {
    velocity.y = jumpForce;
    velocity.x = 150 * directionX;
    _rotationDirection = directionX;
  }

  void triggerDeathSpin() {
    _isDying = true;
    _deathTimer = 0;
    _deathSpinSpeed = 3.0;
    velocity = Vector2.zero();
  }

  void reset() {
    angle = 0;
    scale = Vector2.all(1.0);
    _rotationDirection = 0;
    _isDying = false;
    _deathTimer = 0;
    _deathSpinSpeed = 3.0;
    velocity = Vector2.zero();
    if (_sprite.parent == null) {
      add(_sprite);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle && isVisible && !_isDying) {
      onGameOver();
    }
    super.onCollision(intersectionPoints, other);
  }
}
