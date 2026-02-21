import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'obstacle.dart';
import 'dart:ui';

class CuteGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  late Player player;
  late TextComponent scoreText;

  final Random random = Random();

  double spawnTimer = 0;
  double spawnInterval = 1.5;

  double survivalTime = 0;
  int score = 0;

  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    camera.viewport = FixedResolutionViewport(resolution: Vector2(400, 800));

    player = Player(onGameOver: gameOver);

    add(player);

    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(10, 10),
      priority: 100,
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.black, fontSize: 24),
      ),
    );

    add(scoreText);

    camera.follow(player);
  }

  @override
  void update(double dt) {
    if (isGameOver) return;

    super.update(dt);

    // ⏱ Tiempo sobrevivido
    survivalTime += dt;
    score = survivalTime.floor();
    scoreText.text = '${score}s';

    spawnTimer += dt;

    // dificultad progresiva
    spawnInterval = (1.5 - survivalTime * 0.01).clamp(0.5, 1.5);

    if (spawnTimer > spawnInterval) {
      spawnObstacle();
      spawnTimer = 0;
    }

    // 💀 Muere si cae abajo
    final visibleBottom = camera.visibleWorldRect.bottom;

    if (player.position.y > visibleBottom + 100) {
      gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    drawDynamicBackground(canvas);
    super.render(canvas);
  }

  void drawDynamicBackground(Canvas canvas) {
    final gameSize = size;

    final heightProgress = (survivalTime / 60).clamp(0.0, 1.0);

    final topColor = Color.lerp(
      const Color(0xFF87CEEB),
      const Color(0xFF000014),
      heightProgress,
    )!;

    final bottomColor = Color.lerp(
      const Color(0xFFBFE9FF),
      const Color(0xFF0B0C2A),
      heightProgress,
    )!;

    final rect = Rect.fromLTWH(0, 0, gameSize.x, gameSize.y);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, bottomColor],
    );

    final paint = Paint()..shader = gradient.createShader(rect);

    canvas.drawRect(rect, paint);

    if (heightProgress > 0.4) {
      drawStars(canvas, rect, heightProgress);
    }
  }

  void drawStars(Canvas canvas, Rect rect, double intensity) {
    final starPaint = Paint()..color = Colors.white.withOpacity(intensity);

    for (int i = 0; i < 40; i++) {
      final x = rect.left + random.nextDouble() * rect.width;
      final y = rect.top + random.nextDouble() * rect.height;

      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2, starPaint);
    }
  }

  void spawnObstacle() {
    final visibleTop = camera.visibleWorldRect.top;
    final visibleLeft = camera.visibleWorldRect.left;
    final visibleRight = camera.visibleWorldRect.right;

    final obstacleCount = 2 + random.nextInt(3); // 2 a 4 por spawn

    for (int i = 0; i < obstacleCount; i++) {
      final type = random.nextInt(3);

      if (type == 0) {
        // Desde izquierda
        add(
          Obstacle(
            position: Vector2(
              visibleLeft - 50,
              visibleTop - random.nextInt(400),
            ),
            moveLeft: false,
          ),
        );
      } else if (type == 1) {
        // Desde derecha
        add(
          Obstacle(
            position: Vector2(
              visibleRight + 50,
              visibleTop - random.nextInt(400),
            ),
            moveLeft: true,
          ),
        );
      } else {
        // Desde arriba cayendo
        add(
          Obstacle(
            position: Vector2(
              visibleLeft + random.nextDouble() * (visibleRight - visibleLeft),
              visibleTop - 50,
            ),
            moveLeft: false,
            falling: true,
          ),
        );
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;

    final tapX = event.canvasPosition.x;
    final centerX = size.x / 2;

    double direction = tapX < centerX ? -1 : 1;

    player.jump(direction);
  }

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;
    pauseEngine();

    add(
      TextComponent(
        text: 'GAME OVER',
        position: player.position.clone(),
        anchor: Anchor.center,
        priority: 200,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
