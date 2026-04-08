import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrabble/models/board_cell_model.dart';
import 'package:scrabble/providers/auth_provider.dart';
import 'package:scrabble/providers/game_provider.dart';

import '../models/tile_model.dart';

final gameActionsProvider = Provider<GameActions>((ref) => GameActions(ref));

class GameActions {
  final Ref _ref;
  GameActions(this._ref);

  Future<String> createGame(String displayName) async {
    final service = _ref.read(gameServiceProvider);
    final user = _ref.read(currentUserProvider)!;
    final gameId = await service.createGame(user.uid, displayName);
    _ref.read(activeGameIdProvider.notifier).state = gameId;
    return gameId;
  }

  Future<void> joinGame(String gameId, String displayName) async {
    final service = _ref.read(gameServiceProvider);
    final user = _ref.read(currentUserProvider)!;
    await service.joinGame(gameId, user.uid, displayName);
    _ref.read(activeGameIdProvider.notifier).state = gameId;
  }

  void placeTile(BoardCellModel cell) {
    final pending = _ref.read(pendingPlacementProvider);
    if(pending.any((c) => c.row == cell.row && c.col == cell.col)) return;
    _ref.read(pendingPlacementProvider.notifier).state = [...pending, cell];
  }

  void recallTile(BoardCellModel cell) {
    final pending = _ref.read(pendingPlacementProvider);
    _ref.read(pendingPlacementProvider.notifier).state = pending.where((c) => !(c.row == cell.row && c.col == cell.col)).toList();
  }

  void recallAll() {
    _ref.read(pendingPlacementProvider.notifier).state = [];
  }

  Future<void> commitMove(int scoreEarned, String moveDescription) async {
    final gameId = _ref.read(activeGameIdProvider);
    final game = _ref.read(gameStreamProvider).valueOrNull;
    final placement = _ref.read(pendingPlacementProvider);

    if(gameId == null || game == null || placement.isEmpty) return;

    _ref.read(isSubmittingProvider.notifier).state = true;
    try{
      await _ref.read(gameServiceProvider).commitMove(gameId: gameId, currentGame: game, placement: placement, scoreEarned: scoreEarned, moveDescription: moveDescription);
      _ref.read(pendingPlacementProvider.notifier).state = [];
    } finally {
      _ref.read(isSubmittingProvider.notifier).state = false;
    }
  }

  Future<void> passTurn() async {
    final gameId = _ref.read(activeGameIdProvider);
    final game = _ref.read(gameStreamProvider).valueOrNull;
    if(gameId == null || game == null) return;
    await _ref.read(gameServiceProvider).passTurn(gameId, game.currentTurnIndex);
  }

  Future<void> exchangeTiles() async {
    final gameId = _ref.read(activeGameIdProvider);
    final game = _ref.read(gameStreamProvider).valueOrNull;
    final selected = _ref.read(selectedForExchangeProvider);
    if(gameId == null || game == null || selected.isEmpty) return;

    _ref.read(isSubmittingProvider.notifier).state = true;
    try{
      await _ref.read(gameServiceProvider).exchangeTiles(gameId: gameId, currentGame: game, tilesToExchange: selected);
      _ref.read(selectedForExchangeProvider.notifier).state = [];
    } finally {
      _ref.read(isSubmittingProvider.notifier).state = false;
    }
  }

  void toggleExchangeSelection(TileModel tile) {
    final selected = _ref.read(selectedForExchangeProvider);
    final exists = selected.any((t) => t.letter == tile.letter);
    if(exists) {
      _ref.read(selectedForExchangeProvider.notifier).state = selected.where((t) => t.letter != tile.letter).toList();
    } else {
      _ref.read(selectedForExchangeProvider.notifier).state = [...selected, tile];
    }
  }
}