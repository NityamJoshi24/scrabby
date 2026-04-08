import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrabble/core/constants/app_constants.dart';
import 'package:scrabble/core/constants/tile_constants.dart';
import 'package:scrabble/models/board_cell_model.dart';
import 'package:scrabble/models/game_model.dart';
import 'package:scrabble/models/player_model.dart';

import '../models/tile_model.dart';

class GameService {
  static const int _gameCodeLength = 6;
  static const String _gameCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static final Random _gameCodeRandom = Random.secure();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _games =>
      _db.collection(AppConstants.gamesCollection);

  Future<String> createGame(String hostUid, String hostName) async {
    final bag = TileConstants.buildTileBag();

    final hostRack = _drawTiles(bag, AppConstants.rackSize);

    final host = PlayerModel(
      uid: hostUid,
      displayName: hostName,
      rack: hostRack.map(TileModel.fromLetter).toList(),
      score: 0,
      isConnected: true,
    );

    final gameData = {
      AppConstants.fieldBoard: [],
      AppConstants.fieldTileBag: bag,
      AppConstants.fieldPlayers: [host.toJson()],
      AppConstants.fieldCurrentTurn: 0,
      AppConstants.fieldStatus: AppConstants.statusWaiting,
      AppConstants.fieldCreatedAt: DateTime.now().millisecondsSinceEpoch,
      'winnerIndex': null,
      'moveLog': [],
    };

    for (var attempt = 0; attempt < 10; attempt++) {
      final gameId = _generateGameCode();
      final docRef = _games.doc(gameId);
      final created = await _db.runTransaction<bool>((txn) async {
        final snapshot = await txn.get(docRef);
        if (snapshot.exists) return false;

        txn.set(docRef, gameData);
        return true;
      });

      if (created) return gameId;
    }

    throw Exception('Could not create a unique game code. Try again.');
  }

  Future<void> joinGame(String gameId, String guestId, String guestName) async {
    final docRef = _games.doc(gameId);

    await _db.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);
      if (!snapshot.exists) throw Exception('Game not found');

      final data = snapshot.data() as Map<String, dynamic>;
      final status = data[AppConstants.fieldStatus] as String;
      final players = data[AppConstants.fieldPlayers] as List<dynamic>;

      if (status != AppConstants.statusWaiting) {
        throw Exception('Game is no longer open');
      }
      if (players.length >= 2) {
        throw Exception('Game is full');
      }

      final bag = List<String>.from(data[AppConstants.fieldTileBag] as List);
      final guestRack = _drawTiles(bag, AppConstants.rackSize);

      final guest = PlayerModel(
        uid: guestId,
        displayName: guestName,
        rack: guestRack.map(TileModel.fromLetter).toList(),
        score: 0,
        isConnected: true,
      );

      txn.update(docRef, {
        AppConstants.fieldPlayers: [...players, guest.toJson()],
        AppConstants.fieldTileBag: bag,
        AppConstants.fieldStatus: AppConstants.statusActive,
      });
    });
  }

  Stream<GameModel> streamGame(String gameId) {
    return _games.doc(gameId).snapshots().map((snapshot) {
      if (!snapshot.exists) throw Exception('Game not found');
      return GameModel.fromJson(
        snapshot.id,
        snapshot.data() as Map<String, dynamic>,
      );
    });
  }

  Future<void> commitMove({
    required String gameId,
    required GameModel currentGame,
    required List<BoardCellModel> placement,
    required int scoreEarned,
    required String moveDescription,
  }) async {
    final docRef = _games.doc(gameId);

    await _db.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);
      final data = snapshot.data() as Map<String, dynamic>;

      final bag = List<String>.from(data[AppConstants.fieldTileBag] as List);
      final players = (data[AppConstants.fieldPlayers] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();

      final turnIndex = data[AppConstants.fieldCurrentTurn] as int;
      final player = players[turnIndex];

      final updatedRack = List<TileModel>.from(player.rack);
      for (final cell in placement) {
        updatedRack.removeWhere((t) => t.letter == cell.tile!.letter);
      }

      final newTiles = _drawTiles(bag, placement.length);
      updatedRack.addAll(newTiles.map(TileModel.fromLetter));

      players[turnIndex] = player.copyWith(
        score: player.score + scoreEarned,
        rack: updatedRack,
      );

      final existingBoard = List<Map<String, dynamic>>.from(
        data[AppConstants.fieldBoard] as List,
      );
      for (final cell in placement) {
        existingBoard.add(cell.copyWith(isLocked: true).toJson());
      }

      final moveLog = List<String>.from(data['moveLog'] as List? ?? []);
      moveLog.add(moveDescription);

      final nextTurnIndex = turnIndex == 0 ? 1 : 0;
      String newStatus = data[AppConstants.fieldStatus] as String;
      int? winnerIndex;

      if (bag.isEmpty && updatedRack.isEmpty) {
        newStatus = AppConstants.statusFinished;
        // The player who went out gets the sum of opponent's remaining tiles added
        final penalizedPlayers = _applyRackPenalties(
          players,
          outIndex: turnIndex,
        );
        players[0] = penalizedPlayers[0];
        players[1] = penalizedPlayers[1];
        winnerIndex = _determineWinner(players);
      }

      txn.update(docRef, {
        AppConstants.fieldBoard: existingBoard,
        AppConstants.fieldTileBag: bag,
        AppConstants.fieldPlayers: players.map((p) => p.toJson()).toList(),
        AppConstants.fieldCurrentTurn: nextTurnIndex,
        AppConstants.fieldStatus: newStatus,
        'winnerIndex': winnerIndex,
        'moveLog': moveLog,
        'consecutivePasses': 0,
      });
    });
  }

  Future<void> passTurn(String gameId, int currentTurnIndex) async {
    final docRef = _games.doc(gameId);

    await _db.runTransaction((tx) async {
      final snapshot = await tx.get(docRef);
      final data = snapshot.data() as Map<String, dynamic>;

      final consecutivePasses = (data['consecutivePasses'] as int? ?? 0) + 1;
      final nextTurn = currentTurnIndex == 0 ? 1 : 0;
      final players = (data[AppConstants.fieldPlayers] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();

      String newStatus = data[AppConstants.fieldStatus] as String;
      int? winnerIndex;

      // 4 consecutive passes (2 each) ends the game
      if (consecutivePasses >= AppConstants.maxConsecutivePasses) {
        newStatus = AppConstants.statusFinished;
        // Apply rack penalties before determining winner
        final penalizedPlayers = _applyRackPenalties(players);
        winnerIndex = _determineWinner(penalizedPlayers);

        tx.update(docRef, {
          AppConstants.fieldPlayers: penalizedPlayers
              .map((p) => p.toJson())
              .toList(),
          AppConstants.fieldCurrentTurn: nextTurn,
          AppConstants.fieldStatus: newStatus,
          'winnerIndex': winnerIndex,
          'consecutivePasses': consecutivePasses,
          'moveLog': FieldValue.arrayUnion(['Game ended — too many passes']),
        });
        return;
      }

      tx.update(docRef, {
        AppConstants.fieldCurrentTurn: nextTurn,
        AppConstants.fieldStatus: newStatus,
        'consecutivePasses': consecutivePasses,
        'moveLog': FieldValue.arrayUnion([
          '${players[currentTurnIndex].displayName} passed',
        ]),
      });
    });
  }

  Future<void> exchangeTiles({
    required String gameId,
    required GameModel currentGame,
    required List<TileModel> tilesToExchange,
  }) async {
    final docRef = _games.doc(gameId);

    await _db.runTransaction((txn) async {
      final snapshot = await txn.get(docRef);
      final data = snapshot.data() as Map<String, dynamic>;

      final bag = List<String>.from(data[AppConstants.fieldTileBag] as List);
      if (bag.length < tilesToExchange.length) {
        throw Exception('Not enough tiles left in the bag');
      }

      final players = (data[AppConstants.fieldPlayers] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();

      final turnIndex = data[AppConstants.fieldCurrentTurn] as int;
      final player = players[turnIndex];

      final updatedRack = List<TileModel>.from(player.rack);
      for (final tile in tilesToExchange) {
        updatedRack.removeWhere((t) => t.letter == tile.letter);
      }

      final newTiles = _drawTiles(bag, tilesToExchange.length);
      updatedRack.addAll(newTiles.map(TileModel.fromLetter));

      bag.addAll(tilesToExchange.map((t) => t.letter));
      bag.shuffle();

      players[turnIndex] = player.copyWith(rack: updatedRack);

      final nextTurn = turnIndex == 0 ? 1 : 0;

      txn.update(docRef, {
        AppConstants.fieldTileBag: bag,
        AppConstants.fieldPlayers: players.map((p) => p.toJson()).toList(),
        AppConstants.fieldCurrentTurn: nextTurn,
        'moveLog': FieldValue.arrayUnion([
          'Player exchanged ${tilesToExchange.length} tile(s)',
        ]),
      });
    });
  }

  List<String> _drawTiles(List<String> bag, int count) {
    final drawn = <String>[];
    final actualCount = count.clamp(0, bag.length);
    for (int i = 0; i < actualCount; i++) {
      drawn.add(bag.removeLast());
    }
    return drawn;
  }

  int _determineWinner(List<PlayerModel> players) {
    if (players[0].score >= players[1].score) return 0;
    return 1;
  }

  String _generateGameCode() {
    return String.fromCharCodes(
      Iterable.generate(_gameCodeLength, (_) {
        final index = _gameCodeRandom.nextInt(_gameCodeAlphabet.length);
        return _gameCodeAlphabet.codeUnitAt(index);
      }),
    );
  }

  /// Deducts remaining rack tile values from each player's score.
  /// If [outIndex] is provided, that player gains the sum of the other's rack
  /// (standard Scrabble end-game rule when a player goes out).
  List<PlayerModel> _applyRackPenalties(
    List<PlayerModel> players, {
    int? outIndex,
  }) {
    final penalties = players
        .map((p) => p.rack.fold(0, (total, t) => total + t.points))
        .toList();

    if (outIndex != null) {
      // Player who went out gains opponent's penalty; opponent loses nothing extra
      return [
        players[0].copyWith(
          score: outIndex == 0
              ? players[0].score + penalties[1]
              : players[0].score - penalties[0],
        ),
        players[1].copyWith(
          score: outIndex == 1
              ? players[1].score + penalties[0]
              : players[1].score - penalties[1],
        ),
      ];
    }

    // Both players deduct their own rack value (consecutive pass ending)
    return [
      players[0].copyWith(score: players[0].score - penalties[0]),
      players[1].copyWith(score: players[1].score - penalties[1]),
    ];
  }
}
