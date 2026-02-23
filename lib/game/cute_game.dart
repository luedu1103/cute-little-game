import 'dart:math';
import 'package:cute_game/game/game_over.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'obstacle.dart';

class CuteGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  late Player player;
  late TextComponent scoreText;
  late TextComponent highScoreText;

  final Random random = Random();

  double spawnTimer = 0;
  double spawnInterval = 1.5;

  double survivalTime = 0;
  int score = 0;
  int highScore = 0;

  bool isGameOver = false;

  TextComponent? gameOverText;

  @override
  Future<void> onLoad() async {
    camera.viewport = MaxViewport();

    player = Player(onGameOver: gameOver);

    add(player);

    scoreText = TextComponent(
      text: '0s',
      position: Vector2(size.x / 2, size.y * 0.15),
      anchor: Anchor.center,
      priority: 100,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    add(scoreText);

    highScoreText = TextComponent(
      text: 'Best: 0s',
      position: Vector2(size.x / 2, size.y * 0.22),
      anchor: Anchor.center,
      priority: 100,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    add(highScoreText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // ⏱ Tiempo sobrevivido
    survivalTime += dt;
    score = survivalTime.floor();
    scoreText.text = '${score}s';

    scoreText.textRenderer = TextPaint(
      style: TextStyle(
        color: survivalTime > 40 ? Colors.white : Colors.black,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    spawnTimer += dt;

    // dificultad progresiva
    spawnInterval = (1.5 - survivalTime * 0.01).clamp(0.5, 1.5);

    if (spawnTimer > spawnInterval) {
      spawnObstacle();
      spawnTimer = 0;
    }

    if (player.position.y > size.y + 50) {
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
    final worldWidth = size.x;
    final visibleRect = camera.visibleWorldRect;

    final visibleTop = visibleRect.top;
    final visibleBottom = visibleRect.bottom;

    final obstacleCount = 2 + random.nextInt(3);

    for (int i = 0; i < obstacleCount; i++) {
      final type = random.nextInt(3);

      final randomY =
          visibleTop + random.nextDouble() * (visibleBottom - visibleTop);

      if (type == 0) {
        add(Obstacle(position: Vector2(-60, randomY), moveLeft: false));
      } else if (type == 1) {
        add(
          Obstacle(position: Vector2(worldWidth + 60, randomY), moveLeft: true),
        );
      } else {
        add(
          Obstacle(
            position: Vector2(random.nextDouble() * worldWidth, visibleTop),
            moveLeft: false,
            falling: true,
          ),
        );
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) {
      restartGame();
      return;
    }

    final tapX = event.canvasPosition.x;
    final centerX = size.x / 2;
    player.jump(tapX < centerX ? -1 : 1);
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;

    if (score > highScore) {
      highScore = score;
      highScoreText.text = 'Best: ${highScore}s';
    }

    camera.viewport.add(GameOverOverlay(size));

    gameOver();
  }

  void restartGame() {
    survivalTime = 0;
    score = 0;
    spawnTimer = 0;
    spawnInterval = 1.5;
    isGameOver = false;

    scoreText.text = '0s';
    scoreText.textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    // Eliminar obstáculos
    children.whereType<Obstacle>().toList().forEach(
      (o) => o.removeFromParent(),
    );

    // Eliminar overlay y texto del viewport
    camera.viewport.children.whereType<GameOverOverlay>().toList().forEach(
      (o) => o.removeFromParent(),
    );

    gameOverText?.removeFromParent();
    gameOverText = null;

    // Resetear player
    player.position = Vector2(size.x / 2, size.y / 2);
    player.velocity = Vector2.zero();
  }
}
