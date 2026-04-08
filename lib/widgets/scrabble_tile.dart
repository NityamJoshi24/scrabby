import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/tile_model.dart';

class ScrabbleTile extends StatelessWidget {
  final TileModel tile;
  final double size;
  final bool isSelected;
  final bool isPending;
  final VoidCallback? onTap;

  const ScrabbleTile({super.key,
  required this.tile,
    this.size = 40,
    this.isSelected = false,
    this.isPending = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letterFontSize = (size * 0.52).clamp(12.0, size * 0.52);
    final pointFontSize = (size * 0.22).clamp(7.0, size * 0.22);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(duration: Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPending
              ? const Color(0xFFE0B46A)
              : isSelected
              ? const Color(0xFFF0C97D)
              : const Color(0xFFF3D7AE),
          borderRadius: BorderRadius.circular(size * 0.08),
          border: Border.all(
            color: isPending
                ? const Color(0xFF9C6B2F)
                : const Color(0xFFB07A3E),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: Offset(1, 2),
              blurRadius: 2
            ),
          ]
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                tile.displayLetter,
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: GoogleFonts.merriweather(
                  fontSize: letterFontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A2E1A),
                ),
              ),
            ),
            if(tile.points > 0)
              Positioned(
                right: size * 0.07,
                  bottom: size * 0.05,
                  child: Text('${tile.points}',
                  maxLines: 1,
                  style: GoogleFonts.merriweather(
                    fontWeight: FontWeight.w600,
                    fontSize: pointFontSize,
                    color: const Color(0xFF4A2E1A),
                  ),
                  )
              )
          ],
        ),
      ),
    );
  }
}
