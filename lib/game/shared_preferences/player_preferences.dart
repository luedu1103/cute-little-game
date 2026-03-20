import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class PlayerPreferences {
  PlayerPreferences._();
  static final PlayerPreferences instance = PlayerPreferences._();

  static const _keyNickname = 'player_nickname';
  static const _keyUuid = 'player_uuid';

  Future<String> getOrCreateUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_keyUuid);
    if (uuid == null) {
      uuid = const Uuid().v4();
      await prefs.setString(_keyUuid, uuid);
    }
    return uuid;
  }

  Future<String> loadPlayerNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyNickname) ?? '';
  }

  Future<void> savePlayerNickname(String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNickname, nickname);
  }
}
