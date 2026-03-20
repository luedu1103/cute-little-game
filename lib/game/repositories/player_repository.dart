import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerRepository {
  PlayerRepository._();
  static final PlayerRepository instance = PlayerRepository._();

  final _db = FirebaseFirestore.instance;
  CollectionReference get _players => _db.collection('players');

  Future<bool> nicknameExists(String nickname, String currentUuid) async {
    final query = await _players
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return false;
    return query.docs.first.id != currentUuid;
  }

  Future<void> savePlayer(String uuid, String nickname) async {
    final doc = await _players.doc(uuid).get();

    if (doc.exists) {
      await _players.doc(uuid).update({'nickname': nickname});
    } else {
      await _players.doc(uuid).set({'nickname': nickname, 'highScore': 0});
    }
  }

  Future<void> updateNickname(String uuid, String nickname) async {
    await _players.doc(uuid).update({'nickname': nickname});
  }

  Future<void> updateHighScore(String uuid, int score) async {
    final doc = await _players.doc(uuid).get();
    final current = (doc.data() as Map?)?['highScore'] ?? 0;
    if (score > current) {
      await _players.doc(uuid).update({'highScore': score});
    }
  }

  Future<int> getHighScore(String uuid) async {
    final doc = await _players.doc(uuid).get();
    return (doc.data() as Map?)?['highScore'] ?? 0;
  }

  Future<List<Map<String, dynamic>>> getTop100() async {
    final query = await _players
        .orderBy('highScore', descending: true)
        .limit(100)
        .get();

    return query.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {...data, 'uuid': doc.id};
    }).toList();
  }

  Future<Map<String, dynamic>?> getPlayerEntry(String uuid) async {
    final doc = await _players.doc(uuid).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return {...data, 'uuid': uuid};
  }
}
