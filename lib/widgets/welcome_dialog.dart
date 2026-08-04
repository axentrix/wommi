import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

/// Shows the welcome dialog and returns once it's dismissed - call this
/// right before navigating to '/home' at the end of onboarding.
Future<void> showWelcomeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => WelcomeDialog(
      onBegin: () => Navigator.pop(context),
    ),
  );
}

/// Shown once, right after onboarding finishes and before landing on the
/// home screen - a warm first impression that sets expectations for what
/// daily use looks like.
class WelcomeDialog extends StatelessWidget {
  final VoidCallback onBegin;

  const WelcomeDialog({super.key, required this.onBegin});

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
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌸', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Welcome to the\nworld of Wommi!',
                textAlign: TextAlign.center,
                style: GoogleFonts.unbounded(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: WommiColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Do 3 small rituals daily, collect charms, and guide Wommi in your inner world.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: WommiColors.inkDim,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onBegin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WommiColors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 14,
                    shadowColor: WommiColors.cyan.withOpacity(0.38),
                  ),
                  child: Text(
                    'May the journey begin',
                    style: GoogleFonts.unbounded(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
