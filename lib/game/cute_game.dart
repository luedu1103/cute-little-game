import 'dart:math';
import 'package:cute_game/game/components/star.dart';
import 'package:cute_game/game/shared_preferences/score_preferences.dart';
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

const double _skyTransitionDuration = 60.0;
const double _spawnIntervalMax = 1.5;
const double _spawnIntervalMin = 0.5;
const double _spawnDifficultyRate = 0.01;
const int _maxObstaclesPerSpawn = 4;
const double _playerFallLimit = 50.0;

const Color _skyTopDay = Color(0xFF87CEEB);
const Color _skyTopNight = Color(0xFF000014);
const Color _skyBottomDay = Color(0xFFBFE9FF);
const Color _skyBottomNight = Color(0xFF0B0C2A);
const double _starsAppearAt = 0.2;
const int _starCount = 60;

class CuteGame extends FlameGame with HasCollisionDetection, TapCallbacks {
  // Componentes UI
  late Player _player;
  late TextComponent _scoreText;
  late TextComponent _highScoreText;

  // Estado del juego
  GameState _state = GameState.playing;
  double _survivalTime = 0;
  int _score = 0;
  int _highScore = 0;

  // Spawn de obstáculos
  final Random _random = Random();
  double _spawnTimer = 0;
  double _spawnInterval = _spawnIntervalMax;

  // Fondo
  late final Paint _backgroundPaint;
  late final Paint _starPaint;
  late final List<Star> _stars;

  // TextPaints — se recrean solo cuando cambia el color
  late TextPaint _scorePaint;
  late TextPaint _highScorePaint;
  Color _lastTextColor = Colors.black;

  final _scorePrefs = ScorePreferences.instance;

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    _highScore = await _scorePrefs.loadHighScore();

    camera.viewport = MaxViewport();

    _player = Player(onGameOver: _triggerGameOver);
    add(_player);

    _scorePaint = _buildScorePaint(Colors.black);
    _highScorePaint = _buildHighScorePaint(Colors.black);

    _scoreText = TextComponent(
      text: '0s',
      position: Vector2(size.x / 2, size.y * 0.15),
      anchor: Anchor.center,
      priority: 100,
      textRenderer: _scorePaint,
    );

    _highScoreText = TextComponent(
      text: 'Best: ${_highScore}s',
      position: Vector2(size.x / 2, size.y * 0.22),
      anchor: Anchor.center,
      priority: 100,
      textRenderer: _highScorePaint,
    );

    add(_scoreText);
    add(_highScoreText);

    _backgroundPaint = Paint();
    _starPaint = Paint()..style = PaintingStyle.fill;

    _stars = List.generate(
      _starCount,
      (_) => Star(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        speed: 20 + _random.nextDouble() * 60,
        size: 1 + _random.nextDouble() * 2,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_state == GameState.gameOver) return;

    _updateSurvivalTime(dt);
    _updateTextColor();
    _updateStars(dt);
    _updateObstacleSpawn(dt);
    _checkPlayerFell();
  }

  @override
  void render(Canvas canvas) {
    _drawBackground(canvas);
    super.render(canvas);
  }

  // ── Update helpers ──────────────────────────────────────────────────────────

  void _updateSurvivalTime(double dt) {
    _survivalTime += dt;
    _score = _survivalTime.floor();
    _scoreText.text = '${_score}s';
  }

  void _updateTextColor() {
    final progress = (_survivalTime / _skyTransitionDuration).clamp(0.0, 1.0);
    final targetColor = Color.lerp(Colors.black, Colors.white, progress)!;

    if (targetColor != _lastTextColor) {
      _lastTextColor = targetColor;
      _scorePaint = _buildScorePaint(targetColor);
      _highScorePaint = _buildHighScorePaint(targetColor);
      _scoreText.textRenderer = _scorePaint;
      _highScoreText.textRenderer = _highScorePaint;
    }
  }

  void _updateStars(double dt) {
    for (final star in _stars) {
      star.y += star.speed * dt;
      if (star.y > size.y) {
        star.y = 0;
        star.x = _random.nextDouble() * size.x;
      }
    }
  }

  void _updateObstacleSpawn(double dt) {
    _spawnInterval = (_spawnIntervalMax - _survivalTime * _spawnDifficultyRate)
        .clamp(_spawnIntervalMin, _spawnIntervalMax);

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnObstacles();
      _spawnTimer = 0;
    }
  }

  void _checkPlayerFell() {
    if (_player.position.y > size.y + _playerFallLimit) {
      _triggerGameOver();
    }
  }

  // ── Render helpers ──────────────────────────────────────────────────────────

  void _drawBackground(Canvas canvas) {
    final progress = (_survivalTime / _skyTransitionDuration).clamp(0.0, 1.0);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    _backgroundPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(_skyTopDay, _skyTopNight, progress)!,
        Color.lerp(_skyBottomDay, _skyBottomNight, progress)!,
      ],
    ).createShader(rect);

    canvas.drawRect(rect, _backgroundPaint);

    if (progress > _starsAppearAt) _drawStars(canvas, progress);
  }

  void _drawStars(Canvas canvas, double intensity) {
    _starPaint.color = Colors.white.withOpacity(intensity);
    for (final star in _stars) {
      canvas.drawCircle(Offset(star.x, star.y), star.size, _starPaint);
    }
  }

  // ── Spawn ───────────────────────────────────────────────────────────────────

  void _spawnObstacles() {
    final count = 2 + _random.nextInt(_maxObstaclesPerSpawn - 1);

    for (int i = 0; i < count; i++) {
      switch (_random.nextInt(3)) {
        case 0:
          add(Obstacle(position: Vector2(-60, _randomY()), moveLeft: false));
        case 1:
          add(
            Obstacle(
              position: Vector2(size.x + 60, _randomY()),
              moveLeft: true,
            ),
          );
        case 2:
          add(
            Obstacle(
              position: Vector2(_random.nextDouble() * size.x, 0),
              moveLeft: false,
              falling: true,
            ),
          );
      }
    }
  }

  double _randomY() => _random.nextDouble() * size.y;

  // ── Input ───────────────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    switch (_state) {
      case GameState.playing:
        _player.jump(event.canvasPosition.x < size.x / 2 ? -1 : 1);
      case GameState.dying:
        return;
      case GameState.gameOver:
        _restartGame();
    }
  }

  // ── Estado del juego ────────────────────────────────────────────────────────

  void _triggerGameOver() {
    if (_state != GameState.playing) return;
    _state = GameState.dying;

    if (_score > _highScore) {
      _highScore = _score;
      _highScoreText.text = 'Best: ${_highScore}s';
      _scorePrefs.saveHighScore(_highScore);
    }

    _player.isVisible = false;

    add(
      RainbowExplosion(
        explosionPosition: _player.position.clone(),
        gameSize: size,
        onFinished: _showGameOverScreen,
      ),
    );
  }

  void _showGameOverScreen() {
    _state = GameState.gameOver;
    camera.viewport.add(GameOverOverlay(size));
  }

  void _restartGame() {
    _state = GameState.playing;
    _survivalTime = 0;
    _score = 0;
    _spawnTimer = 0;
    _spawnInterval = _spawnIntervalMax;
    _lastTextColor = Colors.black;

    _scorePaint = _buildScorePaint(Colors.black);
    _highScorePaint = _buildHighScorePaint(Colors.black);

    _scoreText
      ..text = '0s'
      ..textRenderer = _scorePaint;
    _highScoreText.textRenderer = _highScorePaint;

    children.whereType<Obstacle>().toList().forEach(
      (o) => o.removeFromParent(),
    );
    camera.viewport.children.whereType<GameOverOverlay>().toList().forEach(
      (o) => o.removeFromParent(),
    );

    _player
      ..isVisible = true
      ..position = Vector2(size.x / 2, size.y / 2)
      ..velocity = Vector2.zero();
  }

  // ── Factories de TextPaint ──────────────────────────────────────────────────

  static TextPaint _buildScorePaint(Color color) => TextPaint(
    style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold),
  );

  static TextPaint _buildHighScorePaint(Color color) => TextPaint(
    style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w500),
  );
}
