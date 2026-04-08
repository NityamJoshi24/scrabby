import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/models/tile_model.dart';
import 'package:scrabble/providers/game_provider.dart';
import 'package:scrabble/widgets/scrabble_tile.dart';

class TileRack extends ConsumerWidget {
  final List<TileModel> tiles;
  final bool isMyTurn;

  const TileRack({super.key, required this.tiles, required this.isMyTurn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingPlacement = ref.watch(pendingPlacementProvider);
    final selectedRackTile = ref.watch(selectedRackTileProvider);
    final selectedForExchange = ref.watch(selectedForExchangeProvider);
    final isExchangeMode = selectedForExchange.isNotEmpty;
    final placedLetters = pendingPlacement.map((c) => c.tile!.letter).toList();
    final visibleTiles = _getRemainingTiles(tiles, placedLetters);
    final slotCount = visibleTiles.length + pendingPlacement.length;
    final useTapPlacementOnly =
        kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);

    return LayoutBuilder(
      builder: (context, constraints) {
        const horizontalPadding = 24.0;
        const preferredGap = 6.0;
        final availableWidth = (constraints.maxWidth - horizontalPadding).clamp(
          0.0,
          double.infinity,
        );
        final gapsWidth = slotCount * preferredGap;
        final tileSize = slotCount == 0
            ? 44.0
            : ((availableWidth - gapsWidth) / slotCount).clamp(32.0, 44.0);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE7C69B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMyTurn
                  ? const Color(0xFFE7C46B)
                  : const Color(0xFFD2AD7D),
              width: isMyTurn ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isMyTurn ? 'YOUR TURN' : 'OPPONENT\'S TURN',
                style: GoogleFonts.merriweather(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isMyTurn
                      ? const Color(0xFFE7C46B)
                      : const Color(0xFF8A6645),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: preferredGap,
                runSpacing: preferredGap,
                children: [
                  ...visibleTiles.map((tile) {
                    final isSelectedForExchange = selectedForExchange.any(
                      (t) => t.letter == tile.letter,
                    );
                    final isSelectedForPlacement =
                        selectedRackTile != null &&
                        identical(selectedRackTile, tile);

                    return _buildDraggableTile(
                      context,
                      ref,
                      tile,
                      isSelectedForExchange || isSelectedForPlacement,
                      isMyTurn,
                      isExchangeMode,
                      useTapPlacementOnly,
                      tileSize,
                    );
                  }),

                  ...List.generate(pendingPlacement.length, (_) {
                    return _GhostSlot(size: tileSize);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableTile(
    BuildContext context,
    WidgetRef ref,
    TileModel tile,
    bool isSelected,
    bool isMyTurn,
    bool isExchangeMode,
    bool useTapPlacementOnly,
    double tileSize,
  ) {
    if (!isMyTurn) {
      return ScrabbleTile(tile: tile, size: tileSize);
    }

    final tileWidget = ScrabbleTile(
      tile: tile,
      size: tileSize,
      isSelected: isSelected,
      onTap: () {
        if (isExchangeMode) {
          ref.read(selectedForExchangeProvider.notifier).update((s) {
            final exists = s.any((t) => t.letter == tile.letter);
            return exists
                ? s.where((t) => t.letter != tile.letter).toList()
                : [...s, tile];
          });
        } else {
          ref.read(selectedRackTileProvider.notifier).update((selected) {
            return identical(selected, tile) ? null : tile;
          });
        }
      },
    );

    if (useTapPlacementOnly) {
      return tileWidget;
    }

    return Draggable<TileModel>(
      data: tile,
      feedback: Material(
        color: Colors.transparent,
        child: ScrabbleTile(tile: tile, size: tileSize + 4),
      ),
      childWhenDragging: _GhostSlot(size: tileSize),
      child: tileWidget,
    );
  }

  List<TileModel> _getRemainingTiles(
    List<TileModel> rack,
    List<String> placedLetters,
  ) {
    final remaining = List<TileModel>.from(rack);
    for (final letter in placedLetters) {
      final idx = remaining.indexWhere((t) => t.letter == letter);
      if (idx != -1) remaining.removeAt(idx);
    }
    return remaining;
  }
}

class _GhostSlot extends StatelessWidget {
  final double size;
  const _GhostSlot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7EA),
        borderRadius: BorderRadius.circular(size * 0.08),
        border: Border.all(
          color: const Color(0xFFD2AD7D),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
    );
  }
}
