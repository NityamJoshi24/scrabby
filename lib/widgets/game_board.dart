import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrabble/core/constants/board_constants.dart';
import 'package:scrabble/models/board_cell_model.dart';
import 'package:scrabble/models/tile_model.dart';
import 'package:scrabble/providers/game_actions_provider.dart';
import 'package:scrabble/providers/game_provider.dart';
import 'package:scrabble/widgets/board_cell.dart';

import '../models/game_model.dart';

class GameBoard extends ConsumerWidget {
  final GameModel game;
  final TileModel? draggingTile;

  const GameBoard({super.key, required this.game, this.draggingTile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingPlacements = ref.watch(pendingPlacementProvider);
    final selectedRackTile = ref.watch(selectedRackTileProvider);
    final isMyTurn = ref.watch(isMyTurnProvider);

    return LayoutBuilder(
      builder: (context, constrains) {
        final shortestSide = [constrains.maxWidth, constrains.maxHeight]
            .where((dimension) => dimension.isFinite && dimension > 0)
            .fold<double>(
              constrains.maxWidth,
              (current, dimension) => dimension < current ? dimension : current,
            );
        final boardExtent = shortestSide.isFinite && shortestSide > 0
            ? shortestSide
            : constrains.maxWidth;
        final rawCellSize = boardExtent / BoardConstants.boardSize;
        final cellSize = rawCellSize.clamp(0.0, 48.0);
        final boardSize = cellSize * BoardConstants.boardSize;

        return Center(
          child: SizedBox(
            width: boardSize,
            height: boardSize,
            child: _buildGrid(
              context,
              ref,
              cellSize,
              pendingPlacements,
              selectedRackTile,
              isMyTurn,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(
    BuildContext context,
    WidgetRef ref,
    double cellSize,
    List<BoardCellModel> pendingPlacements,
    TileModel? selectedRackTile,
    bool isMyTurn,
  ) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: BoardConstants.boardSize * BoardConstants.boardSize,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: BoardConstants.boardSize,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ BoardConstants.boardSize;
        final col = index % BoardConstants.boardSize;

        return _buildCell(
          context,
          ref,
          row,
          col,
          cellSize,
          pendingPlacements,
          selectedRackTile,
          isMyTurn,
        );
      },
    );
  }

  Widget _buildCell(
    BuildContext context,
    WidgetRef ref,
    int row,
    int col,
    double cellSize,
    List<BoardCellModel> pendingPlacements,
    TileModel? selectedRackTile,
    bool isMyTurn,
  ) {
    final commitedCell = game.board[row][col];
    final pendingCell = pendingPlacements
        .where((c) => c.row == row && c.col == col)
        .firstOrNull;
    final displayCell = pendingCell ?? commitedCell;
    final isPending = pendingCell != null;

    return DragTarget<TileModel>(
      onWillAcceptWithDetails: (details) {
        return isMyTurn && commitedCell.isEmpty && pendingCell == null;
      },
      onAcceptWithDetails: (details) {
        final cell = BoardCellModel(
          row: row,
          col: col,
          tile: details.data,
          isLocked: false,
        );
        ref.read(gameActionsProvider).placeTile(cell);
        ref.read(selectedRackTileProvider.notifier).state = null;
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: Duration(milliseconds: 100),
          decoration: isHovered
              ? BoxDecoration(border: Border.all(color: Colors.white, width: 2))
              : null,
          child: BoardCell(
            cell: displayCell,
            cellSize: cellSize,
            isPending: isPending,
            onTap: isPending && isMyTurn
                ? () => ref.read(gameActionsProvider).recallTile(displayCell)
                : isMyTurn && commitedCell.isEmpty && selectedRackTile != null
                ? () {
                    final cell = BoardCellModel(
                      row: row,
                      col: col,
                      tile: selectedRackTile,
                      isLocked: false,
                    );
                    ref.read(gameActionsProvider).placeTile(cell);
                    ref.read(selectedRackTileProvider.notifier).state = null;
                  }
                : null,
          ),
        );
      },
    );
  }
}
