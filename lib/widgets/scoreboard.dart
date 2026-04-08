import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/models/player_model.dart';

class Scoreboard extends StatelessWidget {
  final PlayerModel me;
  final PlayerModel? opponent;
  final bool isMyTurn;
  final int tilesRemaining;

  const Scoreboard({
    super.key,
    required this.isMyTurn,
    required this.tilesRemaining,
    required this.me,
    required this.opponent,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12,
            vertical: isCompact ? 6 : 8,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1A3A1A),
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _PlayerScore(
                  player: me,
                  isActive: isMyTurn,
                  alignment: CrossAxisAlignment.start,
                  isCompact: isCompact,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$tilesRemaining',
                      style: GoogleFonts.merriweather(
                        color: Colors.white,
                        fontSize: isCompact ? 18 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'tiles left',
                      style: GoogleFonts.merriweather(
                        color: Colors.white38,
                        fontSize: isCompact ? 9 : 10,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _PlayerScore(
                  player: opponent,
                  isActive: !isMyTurn,
                  alignment: CrossAxisAlignment.end,
                  isCompact: isCompact,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final PlayerModel? player;
  final bool isActive;
  final CrossAxisAlignment alignment;
  final bool isCompact;

  const _PlayerScore({
    required this.alignment,
    required this.player,
    required this.isActive,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 10,
        vertical: isCompact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? Color(0xFFDDF700).withValues(alpha: 0.6)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: alignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive) ...[
                Icon(
                  Icons.arrow_right,
                  color: const Color(0xFFFDF700),
                  size: isCompact ? 14 : 16,
                ),
                const SizedBox(width: 2),
              ],
              Flexible(
                child: Text(
                  player?.displayName ?? 'Waiting...',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.merriweather(
                    color: isActive ? Color(0xFFFFD700) : Colors.white54,
                    fontSize: isCompact ? 10 : 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${player?.score ?? 0}',
            style: GoogleFonts.merriweather(
              color: Colors.white,
              fontSize: isCompact ? 20 : 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
