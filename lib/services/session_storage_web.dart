// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

class SavedGameSession {
  final String gameId;
  final bool isHost;

  const SavedGameSession({required this.gameId, required this.isHost});
}

class SessionStorage {
  static const _gameIdKey = 'scrabble.activeGameId';
  static const _isHostKey = 'scrabble.activeGameIsHost';

  Future<SavedGameSession?> readGameSession() async {
    final gameId = html.window.localStorage[_gameIdKey];
    if (gameId == null || gameId.isEmpty) return null;

    return SavedGameSession(
      gameId: gameId,
      isHost: html.window.localStorage[_isHostKey] == 'true',
    );
  }

  Future<void> saveGameSession({
    required String gameId,
    required bool isHost,
  }) async {
    html.window.localStorage[_gameIdKey] = gameId;
    html.window.localStorage[_isHostKey] = isHost.toString();
  }

  Future<void> clearGameSession() async {
    html.window.localStorage.remove(_gameIdKey);
    html.window.localStorage.remove(_isHostKey);
  }
}
