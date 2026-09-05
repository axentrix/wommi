import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';

/// Placeholder for the "Avatar Studio" Rive scene: pick a background color
/// and an accessory, then save the look to fire [onWin].
class AvatarCustomizationGame extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onPlayed;

  const AvatarCustomizationGame(
      {super.key, required this.onWin, required this.onPlayed});

  @override
  State<AvatarCustomizationGame> createState() =>
      _AvatarCustomizationGameState();
}

class _AvatarCustomizationGameState extends State<AvatarCustomizationGame> {
  static const _swatches = [
    WommiColors.cyan,
    WommiColors.rose,
    WommiColors.lilac,
    WommiColors.gold,
    WommiColors.sage,
  ];
  static const _accessories = ['😊', '😎', '🥰', '🤠', '👑'];

  Color _bgColor = _swatches.first;
  String _accessory = _accessories.first;
  bool _saved = false;

  void _save() {
    if (_saved) return;
    setState(() => _saved = true);
    widget.onPlayed();
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
                'Avatar Studio',
                style: GoogleFonts.unbounded(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: WommiColors.ink,
                ),
              ),
              const SizedBox(height: 28),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _bgColor.withOpacity(0.55),
                  border: Border.all(color: _bgColor, width: 3),
                ),
                child: Center(
                  child: Text(_accessory, style: const TextStyle(fontSize: 64)),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'BACKGROUND',
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
                  for (final color in _swatches)
                    GestureDetector(
                      onTap: () => setState(() => _bgColor = color),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: _bgColor == color
                                ? WommiColors.ink
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'ACCESSORY',
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
                  for (final accessory in _accessories)
                    GestureDetector(
                      onTap: () => setState(() => _accessory = accessory),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accessory == accessory
                              ? WommiColors.lilac
                              : Colors.transparent,
                          border: Border.all(color: WommiColors.line),
                        ),
                        child: Text(accessory,
                            style: const TextStyle(fontSize: 20)),
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
                  _saved ? 'Charm collected!' : 'Save Look',
                  style:
                      GoogleFonts.unbounded(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
