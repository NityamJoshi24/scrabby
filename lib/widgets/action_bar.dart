import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/game_actions_provider.dart';
import '../providers/game_provider.dart';
import '../providers/validation_provider.dart';

class ActionBar extends ConsumerWidget {
  const ActionBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMyTurn = ref.watch(isMyTurnProvider);
    final isSubmitting = ref.watch(isSubmittingProvider);
    final pendingPlacements = ref.watch(pendingPlacementProvider);
    final validation = ref.watch(validationProvider);
    final actions = ref.read(gameActionsProvider);

    final hasPending = pendingPlacements.isNotEmpty;

    if (!isMyTurn) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Validation feedback
          if (hasPending) ...[
            if (validation.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  validation.error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            if (validation.canPlay)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  validation.words.map((w) => w.word).join(' · '),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],

          // Button row
          _NormalModeBar(
            hasPending: hasPending,
            pendingScore: validation.score,
            canPlay: validation.canPlay,
            isSubmitting: isSubmitting,
            onPlay: () => actions.commitMove(
              validation.score,
              '${ref.read(myPlayerProvider)?.displayName} played '
              '${validation.words.map((w) => w.word).join(', ')} '
              'for ${validation.score} pts',
            ),
            onRecall: () => actions.recallAll(),
            onPass: () => _confirmPass(context, actions),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPass(BuildContext context, GameActions actions) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pass Turn?'),
        content: const Text('Are you sure you want to pass your turn?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Pass',
              style: TextStyle(color: Color(0xFF8A3A24)),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await actions.passTurn();
  }
}

// ─── Normal mode ──────────────────────────────────────────────────────────────

class _NormalModeBar extends StatelessWidget {
  final bool hasPending;
  final int pendingScore;
  final bool canPlay;
  final bool isSubmitting;
  final VoidCallback onPlay;
  final VoidCallback onRecall;
  final VoidCallback onPass;

  const _NormalModeBar({
    required this.hasPending,
    required this.pendingScore,
    required this.canPlay,
    required this.isSubmitting,
    required this.onPlay,
    required this.onRecall,
    required this.onPass,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        if (hasPending)
          _ActionButton(
            label: 'Recall',
            icon: Icons.undo,
            color: const Color(0xFF8A6645),
            onTap: onRecall,
          ),
        _ActionButton(
          label: hasPending
              ? (canPlay ? 'Play  +$pendingScore' : 'Invalid')
              : 'Play',
          icon: Icons.check_circle_outline,
          color: hasPending && canPlay
              ? const Color(0xFF8A5A2D)
              : const Color(0xFF9A7B5A),
          isLoading: isSubmitting,
          onTap: hasPending && canPlay && !isSubmitting ? onPlay : null,
        ),
        _ActionButton(
          label: 'Pass',
          icon: Icons.skip_next,
          color: const Color(0xFFB9824F),
          onTap: !isSubmitting && !hasPending ? onPass : null,
        ),
      ],
    );
  }
}

// ─── Reusable button ──────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDisabled ? const Color(0xFF9A7B5A) : color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: GoogleFonts.merriweather(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
