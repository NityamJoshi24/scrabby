import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrabble/core/utils/placement_validator.dart';
import 'package:scrabble/core/utils/score_calculator.dart';
import 'package:scrabble/core/utils/word_extractor.dart';
import 'package:scrabble/providers/game_provider.dart';
import 'package:scrabble/services/dictionary_service.dart';

class ValidationResult {
  final bool canPlay;
  final int score;
  final List<FoundWord> words;
  final String? error;

  const ValidationResult({
    required this.canPlay,
    required this.score,
    required this.words,
    this.error,
});

  static const empty = ValidationResult(canPlay: false, score: 0, words: []);
}

final validationProvider = Provider<ValidationResult>((ref) {
  final game = ref.watch(gameStreamProvider).valueOrNull;
  final placements = ref.watch(pendingPlacementProvider);
  final isMyTurn = ref.watch(isMyTurnProvider);

  if(game == null || placements.isEmpty || !isMyTurn) {
    return ValidationResult.empty;
  }

  final placementError = PlacementValidator.validate(placements: placements, game: game);
  if(placementError != PlacementError.none) {
    return ValidationResult(canPlay: false, score: 0, words: [], error: _placementErrorMessage(placementError));
  }

  final words = WordExtractor.extractWords(placements: placements, game: game);
  if(words.isEmpty) {
    return const ValidationResult(canPlay: false, score: 0, words: [], error: 'No words found');
  }

  final dictionary = DictionaryService();
  final invalidWords = words.map((w) => w.word).where((w) => !dictionary.isValidWord(w)).toList();
  if(invalidWords.isNotEmpty) {
    return ValidationResult(canPlay: false, score: 0, words: [], error: '${invalidWords.join(', ')} — not in dictionary');
  }

  final score = ScoreCalculator.calculate(words: words, placements: placements);
  return ValidationResult(canPlay: true, score: score, words: words);
});

String _placementErrorMessage(PlacementError error) {
  switch (error) {
    case PlacementError.notInLines:
      return 'Tiles must be in a straight line';
    case PlacementError.hasGap:
      return 'No gaps allowed between tiles';
    case PlacementError.notConnected:
      return 'Must connect to an existing word';
    case PlacementError.mustCoverCenter:
      return 'First word must cover the center star';
    default:
      return 'Invalid placement';
  }
}