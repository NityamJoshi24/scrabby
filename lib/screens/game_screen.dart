import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/core/constants/app_constants.dart';
import 'package:scrabble/models/game_model.dart';
import 'package:scrabble/models/player_model.dart';
import 'package:scrabble/providers/game_provider.dart';
import 'package:scrabble/screens/result_screen.dart';
import 'package:scrabble/widgets/action_bar.dart';
import 'package:scrabble/widgets/game_board.dart';
import 'package:scrabble/widgets/move_log_sheet.dart';
import 'package:scrabble/widgets/scoreboard.dart';
import 'package:scrabble/widgets/tile_rack.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _navigatedToResult = false;

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(gameStreamProvider);

    return gameAsync.when(
      data: (game) {
        if (game.status == AppConstants.statusFinished && !_navigatedToResult) {
          _navigatedToResult = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ResultScreen(game: game)),
            );
          });
        }

        final me = ref.watch(myPlayerProvider);
        final opponent = ref.watch(opponentProvider);
        final isMyTurn = ref.watch(isMyTurnProvider);

        return Scaffold(
          backgroundColor: const Color(0xFF1B5E20),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A3A1A),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              isMyTurn
                  ? 'Your Turn'
                  : '${opponent?.displayName ?? 'Opponent'}\'s Turn',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.merriweather(
                color: isMyTurn ? const Color(0xFFFFD700) : Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => MoveLogSheet.show(context, game.moveLog),
                icon: const Icon(Icons.history),
                tooltip: 'Move History',
              ),
            ],
          ),
          body: SafeArea(
            child: _GameLayout(
              game: game,
              me: me,
              opponent: opponent,
              isMyTurn: isMyTurn,
            ),
          ),
        );
      },
      error: (e, _) => _ErrorScaffold(error: e.toString()),
      loading: () => _LoadingScaffold(),
    );
  }
}

class _GameLayout extends StatelessWidget {
  final GameModel game;
  final PlayerModel? me;
  final PlayerModel? opponent;
  final bool isMyTurn;

  const _GameLayout({
    required this.game,
    required this.me,
    required this.opponent,
    required this.isMyTurn,
  });

  @override
  Widget build(BuildContext context) {
    final me = this.me;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useWideLayout =
            constraints.maxWidth >= 720 &&
            constraints.maxWidth > constraints.maxHeight;

        final board = InteractiveViewer(
          minScale: 0.6,
          maxScale: 2.5,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: GameBoard(game: game),
            ),
          ),
        );

        final controls = _GameControls(
          game: game,
          me: me,
          opponent: opponent,
          isMyTurn: isMyTurn,
          showScoreboard: useWideLayout,
        );

        if (useWideLayout) {
          return Row(
            children: [
              Expanded(flex: 3, child: board),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                  child: controls,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            if (me != null)
              Scoreboard(
                isMyTurn: isMyTurn,
                tilesRemaining: game.tileBag.length,
                me: me,
                opponent: opponent,
              ),
            Expanded(child: board),
            controls,
          ],
        );
      },
    );
  }
}

class _GameControls extends StatelessWidget {
  final GameModel game;
  final PlayerModel? me;
  final PlayerModel? opponent;
  final bool isMyTurn;
  final bool showScoreboard;

  const _GameControls({
    required this.game,
    required this.me,
    required this.opponent,
    required this.isMyTurn,
    required this.showScoreboard,
  });

  @override
  Widget build(BuildContext context) {
    final me = this.me;
    final opponent = this.opponent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showScoreboard && me != null)
            Scoreboard(
              isMyTurn: isMyTurn,
              tilesRemaining: game.tileBag.length,
              me: me,
              opponent: opponent,
            ),
          if (showScoreboard && me != null) const SizedBox(height: 6),
          if (opponent != null) _OpponentsRack(tileCount: opponent.rack.length),
          if (me != null) TileRack(tiles: me.rack, isMyTurn: isMyTurn),
          const SizedBox(height: 4),
          const ActionBar(),
        ],
      ),
    );
  }
}

class _OpponentsRack extends StatelessWidget {
  final int tileCount;

  const _OpponentsRack({required this.tileCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Opponent: ',
            style: GoogleFonts.merriweather(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
          ...List.generate(tileCount, (_) => _FaceDownTile()),
        ],
      ),
    );
  }
}

class _FaceDownTile extends StatelessWidget {
  const _FaceDownTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 28,
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Color(0xFF5C3D1E),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Color(0xFF8B6340), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B5E20),
      body: Center(child: CircularProgressIndicator(color: Color(0xFFFFD700))),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String error;

  const _ErrorScaffold({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B5E20),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: GoogleFonts.merriweather(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                error,
                style: GoogleFonts.merriweather(
                  color: Colors.white54,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Go Back',
                  style: GoogleFonts.merriweather(color: Color(0xFFFFD700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
