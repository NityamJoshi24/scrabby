import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_model.dart';
import '../models/player_model.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';

class ResultScreen extends ConsumerWidget {
  final GameModel game;
  const ResultScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = ref.read(currentUserProvider)?.uid;
    final me = game.players.where((p) => p.uid == currentUid).firstOrNull;
    final opponent = game.players.where((p) => p.uid != currentUid).firstOrNull;

    final iWon =
        game.winnerIndex != null &&
        game.players[game.winnerIndex!].uid == currentUid;
    final isDraw = me != null && opponent != null && me.score == opponent.score;

    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxHeight < 640 || constraints.maxWidth < 360;
            final padding = constraints.maxWidth < 360 ? 20.0 : 24.0;
            final sectionGap = isCompact ? 24.0 : 48.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    minHeight: constraints.maxHeight - (padding * 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ResultBanner(
                        iWon: iWon,
                        isDraw: isDraw,
                        isCompact: isCompact,
                      ),
                      SizedBox(height: sectionGap),
                      if (me != null)
                        _ScoreCard(player: me, isWinner: iWon, isMe: true),
                      const SizedBox(height: 16),
                      if (opponent != null)
                        _ScoreCard(
                          player: opponent,
                          isWinner: !iWon && !isDraw,
                          isMe: false,
                        ),
                      SizedBox(height: sectionGap),
                      Text(
                        '${game.moveLog.length} moves played',
                        style: GoogleFonts.merriweather(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: sectionGap),
                      _PlayAgainButton(
                        onTap: () async {
                          await ref
                              .read(sessionStorageProvider)
                              .clearGameSession();
                          ref.read(activeGameIdProvider.notifier).state = null;

                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                            (_) => false,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Result banner ────────────────────────────────────────────────────────────

class _ResultBanner extends StatelessWidget {
  final bool iWon;
  final bool isDraw;
  final bool isCompact;

  const _ResultBanner({
    required this.iWon,
    required this.isDraw,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = isDraw
        ? '🤝'
        : iWon
        ? '🏆'
        : '😔';
    final title = isDraw
        ? 'It\'s a Draw!'
        : iWon
        ? 'You Won!'
        : 'You Lost';
    final subtitle = isDraw
        ? 'Great game, equally matched'
        : iWon
        ? 'Excellent vocabulary!'
        : 'Better luck next time';
    final color = isDraw
        ? Colors.white70
        : iWon
        ? const Color(0xFFFFD700)
        : Colors.white54;

    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: isCompact ? 48 : 72)),
        SizedBox(height: isCompact ? 10 : 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.merriweather(
            color: color,
            fontSize: isCompact ? 28 : 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.merriweather(color: Colors.white38, fontSize: 14),
        ),
      ],
    );
  }
}

// ─── Score card ───────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final PlayerModel player;
  final bool isWinner;
  final bool isMe;

  const _ScoreCard({
    required this.player,
    required this.isWinner,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: isWinner
            ? const Color(0xFFFFD700).withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner
              ? const Color(0xFFFFD700).withValues(alpha: 0.5)
              : Colors.white12,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Trophy for winner
          SizedBox(
            width: 32,
            child: isWinner
                ? const Text('🏆', style: TextStyle(fontSize: 22))
                : null,
          ),
          const SizedBox(width: 8),

          // Name + you label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.displayName,
                  style: GoogleFonts.merriweather(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isMe)
                  Text(
                    'You',
                    style: GoogleFonts.merriweather(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          // Score
          Text(
            '${player.score}',
            style: GoogleFonts.merriweather(
              color: isWinner ? const Color(0xFFFFD700) : Colors.white70,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'pts',
            style: GoogleFonts.merriweather(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Play again button ────────────────────────────────────────────────────────

class _PlayAgainButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayAgainButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                'Play Again',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
