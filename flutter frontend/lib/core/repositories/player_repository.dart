import '../../shared/models/player_data.dart';

abstract class PlayerRepository {
  Future<PlayerData> fetchPlayerData();
  Future<void> updatePlayerData(PlayerData data);
}

class InMemoryPlayerRepository implements PlayerRepository {
  PlayerData _current = PlayerData.defaultPlayer;

  @override
  Future<PlayerData> fetchPlayerData() async {
    return _current;
  }

  @override
  Future<void> updatePlayerData(PlayerData data) async {
    _current = data;
  }
}
