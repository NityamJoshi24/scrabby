class SavedGameSession {
  final String gameId;
  final bool isHost;

  const SavedGameSession({required this.gameId, required this.isHost});
}

class SessionStorage {
  Future<SavedGameSession?> readGameSession() async => null;

  Future<void> saveGameSession({
    required String gameId,
    required bool isHost,
  }) async {}

  Future<void> clearGameSession() async {}
}
