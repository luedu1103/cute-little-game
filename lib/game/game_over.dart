import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameOverOverlay extends PositionComponent {
  GameOverOverlay(Vector2 gameSize) {
    size = gameSize;
    anchor = Anchor.topLeft;
    // Asegura que esté por encima de todo
    priority = 10;
  }

  @override
  void render(Canvas canvas) {
    // Fondo semitransparente
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.6);
    canvas.drawRect(size.toRect(), bgPaint);

    // Texto "Game Over"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'GAME OVER',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, size.y / 2 - 60),
    );

    // Subtexto
    final subPainter = TextPainter(
      text: const TextSpan(
        text: 'Toca para reiniciar',
        style: TextStyle(color: Colors.white70, fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    subPainter.paint(
      canvas,
      Offset((size.x - subPainter.width) / 2, size.y / 2 + 10),
    );
  }
}
