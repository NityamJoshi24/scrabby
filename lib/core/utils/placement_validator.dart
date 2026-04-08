import 'package:scrabble/models/board_cell_model.dart';
import 'package:scrabble/models/game_model.dart';

enum PlacementError {
  none,
  noTiles,
  notInLines,
  hasGap,
  notConnected,
  mustCoverCenter,
}

class PlacementValidator {
  static PlacementError validate({
    required List<BoardCellModel> placements,
    required GameModel game,
}) {
    if(placements.isEmpty) return PlacementError.noTiles;

    final rows = placements.map((c) => c.row).toSet();
    final cols = placements.map((c) => c.col).toSet();

    final isHorizontal = rows.length == 1;
    final isVertical = cols.length == 1;
    if(!isHorizontal && !isVertical) return PlacementError.notInLines;

    if(placements.length > 1) {
      if(isHorizontal) {
        final row = rows.first;
        final minCol = cols.reduce((a,b) => a < b ? a : b);
        final maxCol = cols.reduce((a,b) => a > b ? a : b);

        for(int c = minCol; c <= maxCol; c++) {
          final filledByPlacement = placements.any((p) => p.col == c);
          final filledByBoard = game.board[row][c].isOccupied;
          if(!filledByBoard && !filledByPlacement) return PlacementError.hasGap;
        }
      } else {
        final col = cols.first;
        final minRow = rows.reduce((a,b) => a < b ? a : b);
        final maxRow = rows.reduce((a,b) => a > b ? a : b);
        for(int r = minRow; r <= maxRow; r++) {
          final filledByPlacement = placements.any((p) => p.row == r);
          final filledByBoard = game.board[r][col].isOccupied;
          if(!filledByBoard && !filledByPlacement) return PlacementError.hasGap;
        }
      }
    }

    final boardIsEmpty = game.board.expand((row) => row).every((cell) => cell.isEmpty);
    if(boardIsEmpty) {
      final coversCenter = placements.any((p) => p.row == 7 && p.col == 7);
      if(!coversCenter) return PlacementError.mustCoverCenter;
      return PlacementError.none;
    }
    
    final touchesExisting = placements.any((p) => _hasNeighbour(p, game, placements));
    if(!touchesExisting) return PlacementError.notConnected;

    return PlacementError.none;
  }

  static bool _hasNeighbour(
      BoardCellModel cell,
      GameModel game,
      List<BoardCellModel> placements,
      ) {
    final neighbours = [
      [cell.row - 1, cell.col],
      [cell.row + 1, cell.col],
      [cell.row, cell.col - 1],
      [cell.row, cell.col + 1],
    ];

    for(final n in neighbours) {
      final r = n[0];
      final c = n[1];
      if(r < 0 || r > 14 || c < 0 || c > 14) continue;
      if(game.board[r][c].isOccupied && !placements.any((p) => p.row == r && p.col == c)) {
        return true;
      }
    }
    return false;
  }
}