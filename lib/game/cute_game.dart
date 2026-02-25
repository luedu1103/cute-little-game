import 'dart:math';
import 'package:cute_game/game/components/star.dart';
import 'package:flutter/material.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:cute_game/game/ui/game_over.dart';
import 'package:cute_game/game/ui/rainbaw_explosion.dart';
import 'components/player.dart';
import 'components/obstacle.dart';

enum GameState { playing, dying, gameOver }

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

  GameState _state = GameState.playing;

  late final Paint _backgroundPaint;
  late final Paint _starPaint;

  late final List<Star> _stars;

  late final TextPaint _blackScorePaint;
  late final TextPaint _whiteScorePaint;

  @override
  Future<void> onLoad() async {
    camera.viewport = MaxViewport();

    player = Player(onGameOver: gameOver);
    add(player);

    _blackScorePaint = TextPaint(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    _whiteScorePaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    scoreText = TextComponent(
      text: '0s',
      position: Vector2(size.x / 2, size.y * 0.15),
      anchor: Anchor.center,
      priority: 100,
      textRenderer: _blackScorePaint,
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

    // ---- Fondo optimizado ----
    _backgroundPaint = Paint();

    _starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    _stars = [];

    for (int i = 0; i < 60; i++) {
      _stars.add(
        Star(
          x: random.nextDouble() * size.x,
          y: random.nextDouble() * size.y,
          speed: 20 + random.nextDouble() * 60,
          size: 1 + random.nextDouble() * 2,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_state == GameState.gameOver) return;

    survivalTime += dt;
    score = survivalTime.floor();
    scoreText.text = '${score}s';

    // Cambiar renderer sin recrearlo
    scoreText.textRenderer = survivalTime > 40
        ? _whiteScorePaint
        : _blackScorePaint;

    // Movimiento estrellas
    for (final star in _stars) {
      star.y += star.speed * dt;

      if (star.y > size.y) {
        star.y = 0;
        star.x = random.nextDouble() * size.x;
      }
    }

    spawnTimer += dt;

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

    _backgroundPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, bottomColor],
    ).createShader(rect);

    canvas.drawRect(rect, _backgroundPaint);

    if (heightProgress > 0.2) {
      drawStars(canvas, heightProgress);
    }
  }

  void drawStars(Canvas canvas, double intensity) {
    _starPaint.color = Colors.white.withOpacity(intensity);

    for (final star in _stars) {
      canvas.drawCircle(Offset(star.x, star.y), star.size, _starPaint);
    }
  }

  void spawnObstacle() {
    final worldWidth = size.x;
    final worldHeight = size.y;

    final visibleTop = 0.0;
    final visibleBottom = worldHeight;

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
    switch (_state) {
      case GameState.playing:
        player.jump(event.canvasPosition.x < size.x / 2 ? -1 : 1);
        break;
      case GameState.dying:
        return;
      case GameState.gameOver:
        restartGame();
        return;
    }
  }

  void gameOver() {
    if (_state != GameState.playing) return;

    _state = GameState.dying;

    if (score > highScore) {
      highScore = score;
      highScoreText.text = 'Best: ${highScore}s';
    }

    player.isVisible = false;

    add(
      RainbowExplosion(
        explosionPosition: player.position.clone(),
        gameSize: size,
        onFinished: _showGameOverScreen,
      ),
    );
  }

  void _showGameOverScreen() {
    _state = GameState.gameOver;
    camera.viewport.add(GameOverOverlay(size));
  }

  void restartGame() {
    _state = GameState.playing;
    survivalTime = 0;
    score = 0;
    spawnTimer = 0;
    spawnInterval = 1.5;

    scoreText.text = '0s';
    scoreText.textRenderer = _blackScorePaint;

    children.whereType<Obstacle>().toList().forEach(
      (o) => o.removeFromParent(),
    );

    camera.viewport.children.whereType<GameOverOverlay>().toList().forEach(
      (o) => o.removeFromParent(),
    );

    player.isVisible = true;
    player.position = Vector2(size.x / 2, size.y / 2);
    player.velocity = Vector2.zero();
  }
}
