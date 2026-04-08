import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoveLogSheet extends StatelessWidget {
  final List<String> moveLog;

  const MoveLogSheet({super.key, required this.moveLog});

  static void show(BuildContext context, List<String> moveLog) {
    showModalBottomSheet(context: context,
        backgroundColor: Color(0xFF1A3A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
        ),
        builder: (_) => MoveLogSheet(moveLog: moveLog));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(padding: EdgeInsets.all(16),
        child: Text(
          'Move Log',
          style: GoogleFonts.merriweather(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        ),
        Divider(color: Colors.white12,),
        Expanded(child: moveLog.isEmpty
            ? Center(
          child: Text('No Moves Yet',
            style: GoogleFonts.merriweather(
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        )
            : ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            itemBuilder: (_, index) {
            final move = moveLog[moveLog.length -1 - index];
            return Padding(padding: EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text('${moveLog.length - index}',
                    style: GoogleFonts.merriweather(
                      color: Colors.white38,
                      fontSize: 12
                    ),
                  ),
                  SizedBox(width: 16,),
                  Expanded(child: Text(move,
                    style: GoogleFonts.merriweather(
                      color: Colors.white70,
                      fontSize: 13
                    ),
                  ))
                ],
              ),
            );
            },
            separatorBuilder: (_, __) => Divider(color: Colors.white12,),
            itemCount: moveLog.length,
        )
        )
      ],
    );
  }
}
