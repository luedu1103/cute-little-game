import 'package:shared_preferences/shared_preferences.dart';

class ScorePreferences {
  ScorePreferences._();
  static final ScorePreferences instance = ScorePreferences._();

  static const _keyHighScore = 'highScore';

  Future<int> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighScore) ?? 0;
  }

  Future<void> saveHighScore(int highScore) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHighScore, highScore);
  }
}
