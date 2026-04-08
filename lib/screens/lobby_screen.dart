import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/core/constants/app_constants.dart';
import 'package:scrabble/providers/game_provider.dart';

import 'game_screen.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final String gameId;
  final bool isHost;

  const LobbyScreen({super.key, required this.gameId, required this.isHost});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(gameStreamProvider);

    return gameAsync.when(
      data: (game) {
        if (game.status == AppConstants.statusActive && !_navigated) {
          _navigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => GameScreen()),
            );
          });
        }

        return _LobbyShell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: CircularProgressIndicator(
                  color: const Color(0xFFB9824F),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                widget.isHost ? 'Waiting for opponent...' : 'Joining game...',
                style: GoogleFonts.merriweather(
                  color: const Color(0xFF3E2818),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share this code with your opponent',
                style: GoogleFonts.merriweather(
                  color: const Color(0xFF7A5A3A),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.gameId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7EA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFB9824F),
                      width: 2,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.gameId,
                          style: GoogleFonts.merriweather(
                            color: const Color(0xFF8A5A2D),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.copy,
                          color: Color(0xFF8A6645),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _PlayerSlot(
                label: 'Player 1',
                name: game.players.isNotEmpty
                    ? game.players[0].displayName
                    : null,
              ),
              const SizedBox(height: 12),
              _PlayerSlot(
                label: 'Player 2',
                name: game.players.length > 1
                    ? game.players[1].displayName
                    : null,
              ),
            ],
          ),
        );
      },
      error: (e, _) => _LobbyShell(
        child: Text('Error: $e', style: const TextStyle(color: Colors.red)),
      ),
      loading: () => _LobbyShell(
        child: const CircularProgressIndicator(color: Color(0xFFB9824F)),
      ),
    );
  }
}

class _LobbyShell extends StatelessWidget {
  final Widget child;

  const _LobbyShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E7D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE7C69B),
        foregroundColor: const Color(0xFF3E2818),
        title: Text(
          'Game Lobby',
          style: GoogleFonts.merriweather(
            color: const Color(0xFF3E2818),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final padding = EdgeInsets.all(
              constraints.maxWidth < 360 ? 20 : 32,
            );
            final minHeight = constraints.maxHeight > padding.vertical
                ? constraints.maxHeight - padding.vertical
                : 0.0;

            return SingleChildScrollView(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: child,
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

class _PlayerSlot extends StatelessWidget {
  final String label;
  final String? name;

  const _PlayerSlot({required this.label, this.name});

  @override
  Widget build(BuildContext context) {
    final filled = name != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFE7C69B) : const Color(0xFFFFF7EA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: filled ? const Color(0xFFB9824F) : const Color(0xFFD2AD7D),
        ),
      ),
      child: Row(
        children: [
          Icon(
            filled ? Icons.person : Icons.person_outline,
            color: filled ? const Color(0xFF8A5A2D) : const Color(0xFF9A7B5A),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.merriweather(
                    color: const Color(0xFF8A6645),
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  name ?? 'Waiting...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.merriweather(
                    color: filled
                        ? const Color(0xFF3E2818)
                        : const Color(0xFF9A7B5A),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (filled)
            const Icon(Icons.check_circle, color: Color(0xFF8A5A2D), size: 18),
        ],
      ),
    );
  }
}
