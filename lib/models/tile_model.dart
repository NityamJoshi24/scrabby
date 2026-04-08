import 'package:scrabble/core/constants/tile_constants.dart';

class TileModel {
  final String letter;
  final int points;
  final bool isBlank;
  final String? blankAs;

  TileModel({
    required this.letter,
    required this.points,
    this.isBlank = false,
    this.blankAs,
});

  String get displayLetter => isBlank ? (blankAs ?? '') : letter;

  factory TileModel.fromLetter(String letter) {
    return TileModel(letter: letter, points: TileConstants.pointValue(letter), isBlank: letter == '?');
  }

  factory TileModel.fromJson(Map<String, dynamic> json) {
    return TileModel(letter: json['letter'] as String, points: json['points'] as int, isBlank: json['isBlank'] as bool? ?? false, blankAs: json['blankAs'] as String?);
  }

  Map<String, dynamic> toJson() => {
    'letter': letter,
    'points': points,
    'points': points,
    'isBlank': isBlank,
    'blankAs': blankAs,
  };

  TileModel copyWith({
    String? letter,
    int? points,
    bool? isBlank,
    String? blankAs,
}) {
    return TileModel(letter: letter ?? this.letter, points: points ?? this.points, isBlank: isBlank ?? this.isBlank, blankAs: blankAs ?? this.blankAs);
  }
}