import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

/// Placeholder for the "Room Makeover" Rive scene: pick a wallpaper theme
/// and a piece of furniture, then save the room to fire [onWin].
class RoomCustomizationGame extends StatefulWidget {
  final VoidCallback onWin;

  const RoomCustomizationGame({super.key, required this.onWin});

  @override
  State<RoomCustomizationGame> createState() => _RoomCustomizationGameState();
}

class _RoomCustomizationGameState extends State<RoomCustomizationGame> {
  static const _themes = [
    WommiColors.lilac,
    WommiColors.roseSoft,
    WommiColors.goldSoft,
    WommiColors.bgSoft,
  ];
  static const _furniture = ['🛋️', '🪴', '🖼️', '🪑', '🕯️'];

  Color _theme = _themes.first;
  String _furniturePick = _furniture.first;
  bool _saved = false;

  void _save() {
    if (_saved) return;
    setState(() => _saved = true);
    widget.onWin();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WommiColors.bg,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Room Makeover',
                style: GoogleFonts.unbounded(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: WommiColors.ink,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 260,
                height: 170,
                decoration: BoxDecoration(
                  color: _theme,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: WommiColors.line, width: 2),
                ),
                child: Center(
                  child: Text(_furniturePick,
                      style: const TextStyle(fontSize: 56)),
                ),
              ),
              const SizedBox(height: 26),
              Text(
                'WALLPAPER',
                style: GoogleFonts.spaceMono(
                  fontSize: 10.5,
                  letterSpacing: 1.4,
                  color: WommiColors.inkDim,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final color in _themes)
                    GestureDetector(
                      onTap: () => setState(() => _theme = color),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: _theme == color
                                ? WommiColors.ink
                                : WommiColors.line,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'FURNITURE',
                style: GoogleFonts.spaceMono(
                  fontSize: 10.5,
                  letterSpacing: 1.4,
                  color: WommiColors.inkDim,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in _furniture)
                    GestureDetector(
                      onTap: () => setState(() => _furniturePick = item),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _furniturePick == item
                              ? WommiColors.lilac
                              : Colors.transparent,
                          border: Border.all(color: WommiColors.line),
                        ),
                        child: Text(item, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _saved ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: WommiColors.cyan,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  _saved ? 'Charm collected!' : 'Save Room',
                  style: GoogleFonts.unbounded(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
