import 'package:scrabble/models/board_cell_model.dart';
import 'package:scrabble/models/game_model.dart';

class FoundWord {
  final String word;
  final List<BoardCellModel> cells;

  FoundWord({required this.word, required this.cells});
}

class WordExtractor {
  static List<FoundWord> extractWords({
    required List<BoardCellModel> placements,
    required GameModel game,
}) {
    final merged = _buildMergedBoard(game, placements);

    final foundWords = <FoundWord>[];
    final placedPositions = {for(final p in placements) '${p.row},${p.col}'};

    final rows = placements.map((p) => p.row).toSet();
    final isHorizontal = rows.length == 1;

    final mainWord = isHorizontal || placements.length == 1
    ? _extractHorizontalWord(merged, placements.first.row, placements.first.col)
        : _extractVerticalWord(merged, placements.first.row, placements.first.col);

    if(mainWord != null && mainWord.word.length > 1) {
        foundWords.add(mainWord);
    }

    for(final p in placements) {
      final cross = isHorizontal
          ? _extractVerticalWord(merged, p.row, p.col)
          : _extractHorizontalWord(merged, p.row, p.col);

      if(cross != null && cross.word.length > 1) {
        final touchesPlacement = cross.cells.any((c) => placedPositions.contains('${c.row},${c.col}'));
        if(touchesPlacement) foundWords.add(cross);
      }
    }

    return foundWords;
  }

  static List<List<BoardCellModel>> _buildMergedBoard(
      GameModel game,
      List<BoardCellModel> placements,
      ) {
    final merged = game.board.map((row) => row.map((cell) => cell).toList()).toList();

    for(final p in placements) {
      merged[p.row][p.col] = p;
    }
    return merged;
  }

  static FoundWord? _extractHorizontalWord(
      List<List<BoardCellModel>> board,
      int row,
      int col,
      ) {
    int start = col;
    while (start > 0 && board[row][start - 1].isOccupied) start--;
    int end = col;
    while (end < 14 && board[row][end + 1].isOccupied) end++;

    if (start == end) return null;

    final cells = <BoardCellModel>[];
    final buffer = StringBuffer();
    for (int c = start; c <= end; c++) {
      final cell = board[row][c];
      if (cell.isEmpty) return null;
      cells.add(cell);
      buffer.write(cell.tile!.displayLetter);
    }
    return FoundWord(word: buffer.toString(), cells: cells);
  }

  static FoundWord? _extractVerticalWord(
      List<List<BoardCellModel>> board,
      int row,
      int col,
      ) {
    int start = row;
    while (start > 0 && board[start - 1][col].isOccupied) start--;
    int end = row;
    while (end < 14 && board[end + 1][col].isOccupied) end++;

    if (start == end) return null;

    final cells = <BoardCellModel>[];
    final buffer = StringBuffer();
    for (int r = start; r <= end; r++) {
      final cell = board[r][col];
      if (cell.isEmpty) return null;
      cells.add(cell);
      buffer.write(cell.tile!.displayLetter);
    }
    return FoundWord(word: buffer.toString(), cells: cells);
  }
}