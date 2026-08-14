import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/player_data.dart';
import '../repositories/player_repository.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return InMemoryPlayerRepository();
});

class PlayerNotifier extends StateNotifier<PlayerData> {
  final PlayerRepository _repository;

  PlayerNotifier(this._repository) : super(PlayerData.defaultPlayer);

  void setPlayerData(PlayerData data) {
    state = data;
    _repository.updatePlayerData(data);
  }

  void incrementStat(String stat) {
    if (state.remainingPoints <= 0) return;
    final updated = state.copyWith(
      remainingPoints: state.remainingPoints - 1,
      str: stat == 'STR' ? state.str + 1 : state.str,
      agi: stat == 'AGI' ? state.agi + 1 : state.agi,
      vit: stat == 'VIT' ? state.vit + 1 : state.vit,
      intStat: stat == 'INT' ? state.intStat + 1 : state.intStat,
      per: stat == 'PER' ? state.per + 1 : state.per,
    );
    state = updated;
    _repository.updatePlayerData(updated);
  }

  void addExp(int amount) {
    int newExp = state.exp + amount;
    int newLevel = state.level;
    int maxExp = state.maxExp;

    if (newExp >= maxExp) {
      newExp -= maxExp;
      newLevel += 1;
      maxExp = (maxExp * 1.25).round();
    }

    final updated = state.copyWith(
      exp: newExp,
      level: newLevel,
      maxExp: maxExp,
    );
    state = updated;
    _repository.updatePlayerData(updated);
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerData>((ref) {
  final repo = ref.watch(playerRepositoryProvider);
  return PlayerNotifier(repo);
});
