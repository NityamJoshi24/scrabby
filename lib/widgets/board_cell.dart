import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/widgets/scrabble_tile.dart';

import '../core/constants/board_constants.dart';
import '../models/board_cell_model.dart';

class BoardCell extends StatelessWidget {
  final BoardCellModel cell;
  final double cellSize;
  final bool isPending;
  final VoidCallback? onTap;

  const BoardCell({super.key,
  required this.cell,
    required this.cellSize,
    this.isPending = false,
    this.onTap
  });

  static Color _bgColor(BonusType bonus) {
    switch (bonus) {
      case BonusType.tripleWord:   return const Color(0xFFB87852); // walnut
      case BonusType.doubleWord:   return const Color(0xFFD9A273); // cedar
      case BonusType.tripleLetter: return const Color(0xFF8B6B4A); // toasted oak
      case BonusType.doubleLetter: return const Color(0xFFC69C6D); // honey wood
      case BonusType.star:         return const Color(0xFFD9A273); // cedar (center)
      case BonusType.none:         return const Color(0xFFEBD8BE); // maple
    }
  }

  static String _bonusLabel(BonusType bonus) {
    switch (bonus) {
      case BonusType.tripleWord:   return 'TWS';
      case BonusType.doubleWord:   return 'DWS';
      case BonusType.tripleLetter: return 'TLS';
      case BonusType.doubleLetter: return 'DLS';
      case BonusType.star:         return '★';
      case BonusType.none:         return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bonus = BoardConstants.getBonusType(cell.row, cell.col);
    final bg = _bgColor(bonus);
    final label = _bonusLabel(bonus);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(duration: Duration(milliseconds: 100),
        width: cellSize,
        height: cellSize,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.15),
            width: 0.5,
          )
        ),
        child: cell.isOccupied
          ? Padding(padding: EdgeInsets.all(1),
        child: ScrabbleTile(tile: cell.tile!, size: cellSize - 2, isPending: isPending, onTap: onTap,),
        )
            : _BonusLabel(label: label, cellSize: cellSize, bonus: bonus),
      ),
    );
  }
}

class _BonusLabel extends StatelessWidget {
  final String label;
  final double cellSize;
  final BonusType bonus;

  const _BonusLabel({
    required this.label,
    required this.cellSize,
    required this.bonus
  });

  @override
  Widget build(BuildContext context) {
    if(label.isEmpty) return SizedBox.shrink();

    return Center(
      child: Text(label,
      textAlign: TextAlign.center,
        style: GoogleFonts.merriweather(
          fontSize: bonus == BonusType.star ? cellSize * 0.5 : cellSize * 0.2,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFDF6EC),
          height: 1.1,
        ),
      ),
    );
  }
}

