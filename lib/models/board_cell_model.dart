  import 'package:scrabble/models/tile_model.dart';

class BoardCellModel {
  final int row;
  final int col;
  final TileModel? tile;
  final bool isLocked;

  BoardCellModel({
    required this.row,
    required this.col,
    this.tile,
    this.isLocked = false,
});

  bool get isEmpty => tile == null;
  bool get isOccupied => tile != null;

  factory BoardCellModel.fromJson(Map<String, dynamic> json) {
    return BoardCellModel(
      row: json['row'] as int,
      col: json['col'] as int,
      tile: json['tile'] != null
          ? TileModel.fromJson(json['tile'] as Map<String, dynamic>)
          : null,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'tile': tile?.toJson(),
    'isLocked': isLocked,
  };

  BoardCellModel copyWith({
    TileModel? tile,
    bool? isLocked,
  }) {
    return BoardCellModel(
      row: row,
      col: col,
      tile: tile ?? this.tile,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}