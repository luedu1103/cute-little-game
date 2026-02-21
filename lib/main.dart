import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/cute_game.dart';

void main() {
  runApp(
    GameWidget(
      game: CuteGame(),
    ),
  );
}
