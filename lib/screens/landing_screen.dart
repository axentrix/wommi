import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final hasExistingJourney = userState.currentDay > 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.5,
            colors: [
              WommiColors.lilac.withOpacity(0.4),
              WommiColors.bg,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo/Title area
                Text(
                  '🌸',
                  style: TextStyle(fontSize: 80),
                ),
                const SizedBox(height: 24),
                Text(
                  'Wommi',
                  style: GoogleFonts.unbounded(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: WommiColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your fertility companion',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: WommiColors.inkDim,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasExistingJourney
                        ? () {
                            ref.read(userStateProvider.notifier).updateDaysSinceLastOpen();
                            Navigator.of(context).pushReplacementNamed('/home');
                          }
                        : () {
                            Navigator.of(context).pushReplacementNamed('/onboarding');
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: WommiColors.cyan,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 14,
                      shadowColor: WommiColors.cyan.withOpacity(0.38),
                    ),
                    child: Text(
                      hasExistingJourney ? 'Continue Journey' : 'Start Your Journey',
                      style: GoogleFonts.unbounded(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                if (hasExistingJourney) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Reset user state when starting new journey
                        ref.read(userStateProvider.notifier).resetState();
                        Navigator.of(context).pushReplacementNamed('/onboarding');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WommiColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(
                          color: WommiColors.line,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Start a New Journey',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
