import 'package:cute_game/game/cute_game.dart';
import 'package:cute_game/game/repositories/player_repository.dart';
import 'package:cute_game/game/shared_preferences/player_preferences.dart';
import 'package:cute_game/game/ui/widgets/loading_overlay.dart';
import 'package:flutter/material.dart';

class GameOverScreen extends StatefulWidget {
  final CuteGame game;

  const GameOverScreen({super.key, required this.game});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  bool _showLeaderboard = false;
  List<Map<String, dynamic>> _topPlayers = [];
  Map<String, dynamic>? _myEntry;
  bool _loading = false;
  String _currentUuid = '';

  @override
  void initState() {
    super.initState();
    _initUuid();
  }

  Future<void> _initUuid() async {
    _currentUuid = await PlayerPreferences.instance.getOrCreateUuid();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);

    if (_currentUuid.isEmpty) {
      _currentUuid = await PlayerPreferences.instance.getOrCreateUuid();
    }

    final top100 = await PlayerRepository.instance.getTop100();
    final myScore = await PlayerRepository.instance.getPlayerEntry(
      _currentUuid,
    );

    final match = top100.where((p) => p['uuid'] == _currentUuid).toList();

    final inTop = match.isNotEmpty;

    setState(() {
      _topPlayers = top100;
      _myEntry = inTop ? null : myScore;
      _loading = false;
      _showLeaderboard = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _showLeaderboard
          ? Color(0xFF0B0C2A)
          : Colors.black.withOpacity(0.6),
      body: _showLeaderboard ? _buildLeaderboard() : _buildGameOver(),
    );
  }

  Widget _buildGameOver() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${widget.game.score}s',
                style: const TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => widget.game.restartGame(),
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
                  'JUGAR DE NUEVO',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadLeaderboard,
                child: const Text(
                  'Ver Leaderboard',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        if (_loading) const LoadingOverlay(message: 'Cargando ranking...'),
      ],
    );
  }

  Widget _buildLeaderboard() {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: _loading
              ? const LoadingOverlay(message: 'Cargando ranking...')
              : ListView.builder(
                  itemCount: _topPlayers.length + (_myEntry != null ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (_myEntry != null && index == _topPlayers.length) {
                      return const Divider(color: Colors.white24, thickness: 1);
                    }
                    if (_myEntry != null && index == _topPlayers.length + 1) {
                      return _buildEntry(_myEntry!, null, isMe: true);
                    }

                    final player = _topPlayers[index];
                    final isMe = player['uuid'] == _currentUuid;
                    return _buildEntry(player, index + 1, isMe: isMe);
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => setState(() => _showLeaderboard = false),
                child: const Text(
                  'Volver',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              ElevatedButton(
                onPressed: () => widget.game.restartGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'JUGAR',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntry(
    Map<String, dynamic> player,
    int? rank, {
    bool isMe = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.pinkAccent.withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: isMe ? Border.all(color: Colors.pinkAccent, width: 1) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              rank != null ? '#$rank' : '...',
              style: TextStyle(
                color: rank == 1
                    ? Colors.amber
                    : rank == 2
                    ? Colors.grey[300]
                    : rank == 3
                    ? Colors.brown[300]
                    : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              player['nickname'] ?? 'Unknown',
              style: TextStyle(
                color: isMe ? Colors.pinkAccent : Colors.white,
                fontSize: 16,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '${player['highScore']}s',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
