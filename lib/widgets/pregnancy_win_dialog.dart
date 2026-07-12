import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class PregnancyWinDialog extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onNoThanks;

  const PregnancyWinDialog({
    super.key,
    required this.onShare,
    required this.onNoThanks,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: WommiColors.bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration icon
                  Text(
                    '🎉',
                    style: TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Congratulations!',
                    style: GoogleFonts.unbounded(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.rose,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You completed your journey',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: WommiColors.inkDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Necklace visualization (placeholder for Rive)
                  Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: WommiColors.bgSoft,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: WommiColors.line,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '✨💎✨',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Necklace',
                            style: GoogleFonts.unbounded(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: WommiColors.inkDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Share your necklace with a\nrandom user for good luck?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: WommiColors.ink,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(
                children: [
                  // Share button (disabled)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null, // Disabled for now
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WommiColors.rose,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: WommiColors.line,
                        disabledForegroundColor: WommiColors.inkDim,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Share',
                            style: GoogleFonts.unbounded(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // No thanks button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onNoThanks,
                      style: TextButton.styleFrom(
                        foregroundColor: WommiColors.inkDim,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'No, thanks',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
