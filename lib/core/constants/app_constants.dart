class AppConstants {
  static const int rackSize = 7;          // tiles per player rack
  static const int bingoBonus = 50;       // bonus for using all 7 tiles
  static const int maxPlayers = 2;
  static const String blankTile = '?';
  static const int maxConsecutivePasses = 4;

  // Firestore collection/field names
  static const String gamesCollection = 'games';
  static const String fieldBoard = 'board';
  static const String fieldTileBag = 'tileBag';
  static const String fieldPlayers = 'players';
  static const String fieldCurrentTurn = 'currentTurn';
  static const String fieldStatus = 'status';
  static const String fieldCreatedAt = 'createdAt';

  // Game status values
  static const String statusWaiting = 'waiting';
  static const String statusActive = 'active';
  static const String statusFinished = 'finished';
}
