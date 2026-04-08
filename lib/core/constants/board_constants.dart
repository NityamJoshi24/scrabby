enum BonusType {none, doubleLetter, tripleLetter, doubleWord, tripleWord, star}

class BoardConstants {
  static const int boardSize = 15;

  static const Map<String, BonusType> bonusSquares = {
      // Triple Word (TWS) — 8 squares
    '0,0': BonusType.tripleWord,  '0,7': BonusType.tripleWord,
    '0,14': BonusType.tripleWord, '7,0': BonusType.tripleWord,
    '7,14': BonusType.tripleWord, '14,0': BonusType.tripleWord,
    '14,7': BonusType.tripleWord, '14,14': BonusType.tripleWord,

    // Double Word (DWS) — 17 squares (includes center star)
    '7,7': BonusType.star,
    '1,1': BonusType.doubleWord,  '2,2': BonusType.doubleWord,
    '3,3': BonusType.doubleWord,  '4,4': BonusType.doubleWord,
    '1,13': BonusType.doubleWord, '2,12': BonusType.doubleWord,
    '3,11': BonusType.doubleWord, '4,10': BonusType.doubleWord,
    '10,4': BonusType.doubleWord, '11,3': BonusType.doubleWord,
    '12,2': BonusType.doubleWord, '13,1': BonusType.doubleWord,
    '10,10': BonusType.doubleWord,'11,11': BonusType.doubleWord,
    '12,12': BonusType.doubleWord,'13,13': BonusType.doubleWord,

    // Triple Letter (TLS) — 12 squares
    '1,5': BonusType.tripleLetter,  '1,9': BonusType.tripleLetter,
    '5,1': BonusType.tripleLetter,  '5,5': BonusType.tripleLetter,
    '5,9': BonusType.tripleLetter,  '5,13': BonusType.tripleLetter,
    '9,1': BonusType.tripleLetter,  '9,5': BonusType.tripleLetter,
    '9,9': BonusType.tripleLetter,  '9,13': BonusType.tripleLetter,
    '13,5': BonusType.tripleLetter, '13,9': BonusType.tripleLetter,

    // Double Letter (DLS) — 24 squares
    '0,3': BonusType.doubleLetter,  '0,11': BonusType.doubleLetter,
    '2,6': BonusType.doubleLetter,  '2,8': BonusType.doubleLetter,
    '3,0': BonusType.doubleLetter,  '3,7': BonusType.doubleLetter,
    '3,14': BonusType.doubleLetter, '6,2': BonusType.doubleLetter,
    '6,6': BonusType.doubleLetter,  '6,8': BonusType.doubleLetter,
    '6,12': BonusType.doubleLetter, '7,3': BonusType.doubleLetter,
    '7,11': BonusType.doubleLetter, '8,2': BonusType.doubleLetter,
    '8,6': BonusType.doubleLetter,  '8,8': BonusType.doubleLetter,
    '8,12': BonusType.doubleLetter, '11,0': BonusType.doubleLetter,
    '11,7': BonusType.doubleLetter, '11,14': BonusType.doubleLetter,
    '12,6': BonusType.doubleLetter, '12,8': BonusType.doubleLetter,
    '14,3': BonusType.doubleLetter, '14,11': BonusType.doubleLetter,
  };

    static BonusType getBonusType(int row, int col) {
      return bonusSquares['$row,$col'] ?? BonusType.none;
    }
}