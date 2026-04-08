import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrabble/models/board_cell_model.dart';
import 'package:scrabble/models/player_model.dart';
import 'package:scrabble/providers/auth_provider.dart';
import 'package:scrabble/services/game_service.dart';

import '../models/game_model.dart';
import '../models/tile_model.dart';

final gameServiceProvider = Provider<GameService>((ref) => GameService());

final activeGameIdProvider = StateProvider<String?>((ref) => null);

final gameStreamProvider = StreamProvider<GameModel>((ref) {
  final gameId = ref.watch(activeGameIdProvider);
  if(gameId == null) return Stream.empty();

  final service = ref.read(gameServiceProvider);
  return service.streamGame(gameId);
});

final pendingPlacementProvider = StateProvider<List<BoardCellModel>>((ref) => []);

final selectedForExchangeProvider = StateProvider<List<TileModel>>((ref) => []);

final isSubmittingProvider = StateProvider<bool>((ref) => false);

final isMyTurnProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final game = ref.watch(gameStreamProvider).valueOrNull;
  if(user == null || game == null) return false;
  return game.currentPlayer.uid == user.uid;
});

final myPlayerProvider = Provider<PlayerModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  final game = ref.watch(gameStreamProvider).valueOrNull;
  if(user == null || game == null) return null;
  try{
    return game.players.firstWhere((p) => p.uid == user.uid);
  } catch (_) {
    return null;
  }
});

final opponentProvider = Provider<PlayerModel?>((ref) {
  final user = ref.watch(currentUserProvider);
  final game = ref.watch(gameStreamProvider).valueOrNull;
  if(user == null || game == null) return null;
  try{
    return game.players.firstWhere((p) => p.uid != user.uid);
  } catch (_) {
    return null;
  }
});