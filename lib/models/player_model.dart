import 'package:scrabble/models/tile_model.dart';

class PlayerModel {
  final String uid;
  final String displayName;
  final List<TileModel> rack;
  final int score;
  final bool isConnected;

  PlayerModel({
    required this.uid,
    required this.displayName,
    required this.rack,
    this.score = 0,
    this.isConnected = false,
});

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(uid: json['uid'] as String, displayName: json['displayName'] as String, rack: (json['rack'] as List<dynamic>).map((t) => TileModel.fromJson(t as Map<String, dynamic>)).toList(), score: json['score'] as int? ?? 0,
        isConnected: json['isConnected'] as bool? ?? false);
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'rack': rack.map((t) => t.toJson()).toList(),
    'score': score,
    'isConnected': isConnected,
  };

  PlayerModel copyWith({
    String? displayName,
    List<TileModel>? rack,
    bool? isConnected,
    int? score,
}) {
    return PlayerModel(uid: uid, displayName: displayName ?? this.displayName, rack: rack ?? this.rack, score: score ?? this.score, isConnected: isConnected ?? this.isConnected);
  }
}