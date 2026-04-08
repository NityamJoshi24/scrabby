import 'package:scrabble/core/constants/app_constants.dart';
import 'package:scrabble/core/constants/board_constants.dart';
import 'package:scrabble/models/board_cell_model.dart';
import 'package:scrabble/models/player_model.dart';

class GameModel {
  final String gameId;
  final List<List<BoardCellModel>> board;
  final List<String> tileBag;
  final List<PlayerModel> players;
  final int currentTurnIndex;
  final String status;
  final DateTime createdAt;
  final int? winnerIndex;
  final List<String> moveLog;
  final int consecutivePasses;

  GameModel({
    required this.gameId,
    required this.board,
    required this.tileBag,
    required this.players,
    required this.currentTurnIndex,
    required this.status,
    required this.createdAt,
    this.winnerIndex,
    this.moveLog = const [],
    this.consecutivePasses = 0,
});

  PlayerModel get currentPlayer => players[currentTurnIndex];
  PlayerModel get waitingPlayer => players[currentTurnIndex == 0 ? 1 : 0];
  bool get isWaiting => status == AppConstants.statusWaiting;
  bool get isActive => status == AppConstants.statusActive;
  bool get isFinished => status == AppConstants.statusFinished;

  static List<List<BoardCellModel>> _buildBoard(List<dynamic> flat) {
    final grid = List.generate(BoardConstants.boardSize, (r) => List.generate(BoardConstants.boardSize, (c) => BoardCellModel(row: r, col: c)));
    for(final cellJson in flat) {
      final cell = BoardCellModel.fromJson(cellJson as Map<String, dynamic>);
      grid[cell.row][cell.col] = cell;
    }
    return grid;
  }

  static List<Map<String, dynamic>> _flattenBoard(List<List<BoardCellModel>> board) {
    final flat = <Map<String, dynamic>>[];
    for(final row in board) {
      for(final cell in row) {
        if(cell.isOccupied) flat.add(cell.toJson());
      }
    }
    return flat;
  }

  factory GameModel.fromJson(String id, Map<String, dynamic> json) {
    return GameModel(
      gameId: id,
      board: _buildBoard(json[AppConstants.fieldBoard] as List<dynamic>? ?? []),
      tileBag: List<String>.from(
          json[AppConstants.fieldTileBag] as List<dynamic>? ?? []),
      players: (json[AppConstants.fieldPlayers] as List<dynamic>)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      currentTurnIndex: json[AppConstants.fieldCurrentTurn] as int? ?? 0,
      status: json[AppConstants.fieldStatus] as String? ??
          AppConstants.statusWaiting,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          json[AppConstants.fieldCreatedAt] as int? ?? 0),
      winnerIndex: json['winnerIndex'] as int?,
      moveLog: List<String>.from(json['moveLog'] as List<dynamic>? ?? []),
      consecutivePasses: json['consecutivePasses'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    AppConstants.fieldBoard: _flattenBoard(board),
    AppConstants.fieldTileBag: tileBag,
    AppConstants.fieldPlayers: players.map((p) => p.toJson()).toList(),
    AppConstants.fieldCurrentTurn: currentTurnIndex,
    AppConstants.fieldStatus: status,
    AppConstants.fieldCreatedAt: createdAt.millisecondsSinceEpoch,
    'winnerIndex': winnerIndex,
    'moveLog': moveLog,
    'consecutivePasses': consecutivePasses,
  };

  GameModel copyWith({
    List<List<BoardCellModel>>? board,
    List<String>? tileBag,
    List<PlayerModel>? players,
    int? currentTurnIndex,
    String? status,
    int? winnerIndex,
    List<String>? moveLog,
    int? consecutivePasses,
}) {
    return GameModel(gameId: gameId, board: board ?? this.board, tileBag: tileBag ?? this.tileBag, players: players ?? this.players, currentTurnIndex: currentTurnIndex ?? this.currentTurnIndex, status: status ?? this.status, createdAt: createdAt, winnerIndex: winnerIndex ?? this.winnerIndex, moveLog: moveLog ?? this.moveLog, consecutivePasses: currentTurnIndex ?? this.consecutivePasses);
  }
}