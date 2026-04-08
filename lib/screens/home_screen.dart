import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/providers/game_actions_provider.dart';

import 'lobby_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? get _displayName {
    final name = _nameController.text.trim();
    return name.isEmpty ? null : name;
  }

  Future<void> _createGame() async {
    if (_displayName == null) {
      setState(() {
        _error = 'Enter your name first';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final gameId = await ref
          .read(gameActionsProvider)
          .createGame(_displayName!);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyScreen(gameId: gameId, isHost: true),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _joinGame() async {
    if (_displayName == null) {
      setState(() {
        _error = 'Enter your name first';
      });
      return;
    }
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      setState(() {
        _error = 'Game code must be 6 characters';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(gameActionsProvider).joinGame(code, _displayName!);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LobbyScreen(gameId: code, isHost: false),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6E7D0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact =
                constraints.maxHeight < 680 || constraints.maxWidth < 360;
            final padding = constraints.maxWidth < 360 ? 20.0 : 32.0;
            final headerGap = isCompact ? 28.0 : 48.0;
            final sectionGap = isCompact ? 20.0 : 32.0;
            final dividerGap = isCompact ? 16.0 : 24.0;

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(isCompact: isCompact),
                      SizedBox(height: headerGap),
                      _buildLabel('YOUR NAME'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Enter display name',
                        maxLength: 16,
                      ),
                      SizedBox(height: sectionGap),
                      _PrimaryButton(
                        label: 'Create Game',
                        icon: Icons.add_circle_outline,
                        isLoading: _isLoading,
                        onTap: _createGame,
                      ),
                      SizedBox(height: dividerGap),

                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0x55A06D3C)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: GoogleFonts.merriweather(
                                color: const Color(0xFF8A6645),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Color(0x55A06D3C)),
                          ),
                        ],
                      ),
                      SizedBox(height: dividerGap),
                      _buildLabel('GAME CODE'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _codeController,
                        hint: 'Enter 6-character code',
                        maxLength: 6,
                        caps: true,
                      ),
                      const SizedBox(height: 12),
                      _PrimaryButton(
                        label: 'Join Game',
                        icon: Icons.login,
                        isLoading: _isLoading,
                        color: const Color(0xFF8A5A2D),
                        onTap: _joinGame,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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

  Widget _buildHeader({required bool isCompact}) {
    final logoSize = isCompact ? 64.0 : 80.0;
    final titleSize = isCompact ? 30.0 : 36.0;

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: const Color(0xFFF3D7AE),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5A351F).withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'S',
              style: GoogleFonts.merriweather(
                fontSize: isCompact ? 38 : 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3E2818),
              ),
            ),
          ),
        ),
        SizedBox(height: isCompact ? 10 : 16),
        Text(
          'Scrabble',
          style: GoogleFonts.merriweather(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E2818),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Online Multiplayer',
          style: GoogleFonts.merriweather(
            fontSize: 14,
            color: const Color(0xFF7A5A3A),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.merriweather(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF7A5A3A),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int? maxLength,
    bool caps = false,
  }) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      textCapitalization: caps
          ? TextCapitalization.characters
          : TextCapitalization.none,
      inputFormatters: caps
          ? [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
              LengthLimitingTextInputFormatter(maxLength),
              UpperCaseTextFormatter(),
            ]
          : [],
      style: GoogleFonts.merriweather(
        color: const Color(0xFF3E2818),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.merriweather(
          color: const Color(0xFF9A7B5A),
          fontSize: 14,
        ),
        counterStyle: const TextStyle(color: Color(0xFF9A7B5A)),
        filled: true,
        fillColor: const Color(0xFFFFF7EA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD2AD7D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD2AD7D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFB9824F), width: 2),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isLoading;
  final Color color;

  const _PrimaryButton({
    required this.label,
    this.isLoading = false,
    this.color = const Color(0xFFB9824F),
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.merriweather(
                      fontSize: 16,
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
