import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class RainbowExplosion extends PositionComponent {
  final VoidCallback onFinished;
  final Vector2 gameSize;

  bool _finished = false;
  late final SpriteAnimationComponent _animation;

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
    final image = await Flame.images.load('explosion-Sheet.png');

    const frameCount = 9;
    const stepTime = 0.10;

    final animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: Vector2(100, 100),
        loop: false,
      ),
    );

    _animation = SpriteAnimationComponent(
      animation: animation,
      size: Vector2.all(200),
      anchor: Anchor.center,
    );

    add(_animation);

    add(
      TimerComponent(
        period: frameCount * stepTime,
        onTick: () {
          if (!_finished) {
            _finished = true;
            onFinished();
            removeFromParent();
          }
        },
      ),
    );
  }
}
