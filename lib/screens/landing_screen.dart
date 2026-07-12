import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';

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
                // Primary action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: hasExistingJourney
                        ? () async {
                            final userState = ref.read(userStateProvider);
                            final profileId = userState.profileId;

                            // Save current journey to database if user has a profile
                            if (profileId != null && userState.gemBalance > 0) {
                              print('[Landing] Saving current journey before starting new one');
                              await ref.read(repositoryProvider).saveJourneyRecord(
                                    userProfileId: profileId,
                                    journeyNumber: userState.currentJourneyNumber,
                                    gemsCollected: userState.gemBalance,
                                    startDate: userState.lastOpenedDate ?? DateTime.now(),
                                    endDate: DateTime.now(),
                                  );
                            }

                            // Clear all ritual completions and charms for the new journey
                            print('[Landing] Clearing journey progress for new journey');
                            await ref.read(repositoryProvider).clearJourneyProgress();

                            // Now reset and start new journey
                            ref.read(userStateProvider.notifier).resetState();
                            Navigator.of(context).pushReplacementNamed('/onboarding');
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
                      'Start Your Journey',
                      style: GoogleFonts.unbounded(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                if (hasExistingJourney) ...[
                  const SizedBox(height: 24),
                  Text(
                    'I have an active journey',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: WommiColors.inkDim,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      ref.read(userStateProvider.notifier).updateDaysSinceLastOpen();
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: WommiColors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Continue Journey',
                      style: GoogleFonts.unbounded(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: WommiColors.cyan,
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
