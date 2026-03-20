import 'package:cute_game/firebase_options.dart';
import 'package:cute_game/game/ui/game_over.dart';
import 'package:cute_game/game/ui/start_game.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/cute_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameWidget(
        game: CuteGame(),
        overlayBuilderMap: {
          'startMenu': (context, game) => StartMenuOverlay(
            onStart: (nick) => (game as CuteGame).startGame(nick),
          ),
          'gameOver': (context, game) => GameOverScreen(game: game as CuteGame),
        },
        initialActiveOverlays: const ['startMenu'],
      ),
    ),
  );
}
