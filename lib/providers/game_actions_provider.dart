import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrabble/models/board_cell_model.dart';
import 'package:scrabble/providers/auth_provider.dart';
import 'package:scrabble/providers/game_provider.dart';

final gameActionsProvider = Provider<GameActions>((ref) => GameActions(ref));

class GameActions {
  final Ref _ref;
  GameActions(this._ref);

  Future<String> createGame(String displayName) async {
    final service = _ref.read(gameServiceProvider);
    final user = _ref.read(currentUserProvider)!;
    final gameId = await service.createGame(user.uid, displayName);
    _ref.read(activeGameIdProvider.notifier).state = gameId;
    await _ref
        .read(sessionStorageProvider)
        .saveGameSession(gameId: gameId, isHost: true);
    return gameId;
  }

  Future<void> joinGame(String gameId, String displayName) async {
    final service = _ref.read(gameServiceProvider);
    final user = _ref.read(currentUserProvider)!;
    await service.joinGame(gameId, user.uid, displayName);
    _ref.read(activeGameIdProvider.notifier).state = gameId;
    await _ref
        .read(sessionStorageProvider)
        .saveGameSession(gameId: gameId, isHost: false);
  }

  void placeTile(BoardCellModel cell) {
    final pending = _ref.read(pendingPlacementProvider);
    if (pending.any((c) => c.row == cell.row && c.col == cell.col)) return;
    _ref.read(pendingPlacementProvider.notifier).state = [...pending, cell];
  }

  void recallTile(BoardCellModel cell) {
    final pending = _ref.read(pendingPlacementProvider);
    _ref.read(pendingPlacementProvider.notifier).state = pending
        .where((c) => !(c.row == cell.row && c.col == cell.col))
        .toList();
  }

  void recallAll() {
    _ref.read(pendingPlacementProvider.notifier).state = [];
  }

  Future<void> commitMove(int scoreEarned, String moveDescription) async {
    final gameId = _ref.read(activeGameIdProvider);
    final game = _ref.read(gameStreamProvider).valueOrNull;
    final placement = _ref.read(pendingPlacementProvider);

    if (gameId == null || game == null || placement.isEmpty) return;

    _ref.read(isSubmittingProvider.notifier).state = true;
    try {
      await _ref
          .read(gameServiceProvider)
          .commitMove(
            gameId: gameId,
            currentGame: game,
            placement: placement,
            scoreEarned: scoreEarned,
            moveDescription: moveDescription,
          );
      _ref.read(pendingPlacementProvider.notifier).state = [];
    } finally {
      _ref.read(isSubmittingProvider.notifier).state = false;
    }
  }

  Future<void> passTurn() async {
    final gameId = _ref.read(activeGameIdProvider);
    final game = _ref.read(gameStreamProvider).valueOrNull;
    if (gameId == null || game == null) return;
    await _ref
        .read(gameServiceProvider)
        .passTurn(gameId, game.currentTurnIndex);
  }
}
