import 'package:cute_game/game/repositories/player_repository.dart';
import 'package:cute_game/game/shared_preferences/player_preferences.dart';
import 'package:flutter/material.dart';

class StartMenuOverlay extends StatefulWidget {
  final Function(String nickname) onStart;

  const StartMenuOverlay({super.key, required this.onStart});

  @override
  State<StartMenuOverlay> createState() => _StartMenuOverlayState();
}

class _StartMenuOverlayState extends State<StartMenuOverlay> {
  final TextEditingController _controller = TextEditingController();

  final playerPreferences = PlayerPreferences.instance;

  bool _isLoading = false;
  String? _errorText;
  String _currentUuid = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _currentUuid = await playerPreferences.getOrCreateUuid();
    final saved = await playerPreferences.loadPlayerNickname();
    if (saved.isNotEmpty) {
      setState(() => _controller.text = saved);
    }
  }

  Future<void> _onPlay() async {
    final nick = _controller.text.trim();
    if (nick.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final exists = await PlayerRepository.instance.nicknameExists(
      nick,
      _currentUuid,
    );

    if (exists) {
      setState(() {
        _isLoading = false;
        _errorText = 'Ese nickname ya está en uso';
      });
      return;
    }

    await playerPreferences.savePlayerNickname(nick);
    await PlayerRepository.instance.savePlayer(_currentUuid, nick);

    widget.onStart(nick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CUTE JUMPS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 260,
              child: TextField(
                controller: _controller,
                maxLength: 16,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Tu nickname',
                  hintStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.pinkAccent),
                  ),
                  counterStyle: const TextStyle(color: Colors.white54),
                ),
              ),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _onPlay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'JUGAR',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
