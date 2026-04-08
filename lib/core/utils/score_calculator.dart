import 'package:scrabble/core/constants/app_constants.dart';
import 'package:scrabble/core/constants/board_constants.dart';
import 'package:scrabble/core/utils/word_extractor.dart';
import 'package:scrabble/models/board_cell_model.dart';

class ScoreCalculator {
  static int calculate({
    required List<FoundWord> words,
    required List<BoardCellModel> placements,
}) {
    int total = 0;
    final placedKeys = {for(final p in placements) '${p.row},${p.col}'};

    for(final found in words) {
      total += _scoreWord(found.cells, placedKeys);
    }

    if(placements.length == AppConstants.rackSize) {
      total += AppConstants.bingoBonus;
    }

    return total;
  }

  static int _scoreWord(
      List<BoardCellModel> cells,
      Set<String> placedKeys,
      ) {
    int wordScore = 0;
    int wordMultiplier = 1;

    for(final cell in cells) {
      final isNew = placedKeys.contains('${cell.row},${cell.col}');
      final tilePoints = cell.tile!.points;
      final bonus = BoardConstants.getBonusType(cell.row, cell.col);

      int letterScore = tilePoints;
      if(isNew) {
        switch (bonus) {
          case BonusType.doubleLetter:
            letterScore = tilePoints * 2;
          case BonusType.tripleLetter:
            letterScore = tilePoints * 3;
          case BonusType.doubleWord:
          case BonusType.star:
            wordMultiplier *= 2;
          case BonusType.tripleWord:
            wordMultiplier *= 3;
          case BonusType.none:
            break;
        }
      }

      wordScore += letterScore;
    }

    return wordScore * wordMultiplier;
  }
}