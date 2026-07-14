import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/repository_provider.dart';
import '../services/device_storage.dart';
import '../services/local_backup_storage.dart';

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
                            if (profileId != null) {
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
                    onPressed: () async {
                      // Use the same calendar-date-based calculation as
                      // everywhere else, instead of updateDaysSinceLastOpen()
                      // (which tracks its own separate, easily-stale
                      // lastOpenedDate timestamp that can disagree with it).
                      final freshDay = await ref
                          .read(repositoryProvider)
                          .calculateCurrentCycleDay();
                      ref
                          .read(userStateProvider.notifier)
                          .updateCurrentDay(freshDay);
                      if (!context.mounted) return;
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
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => _showResetAllDataDialog(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: WommiColors.inkDim,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Text(
                    'Reset all data (testing)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                      decorationColor: WommiColors.inkDim,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetAllDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset all data?',
          style: GoogleFonts.unbounded(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.red,
          ),
        ),
        content: Text(
          'This wipes every profile, journey, and ritual/charm record in '
          'the local database, plus the remembered email on this device. '
          'For testing only - this cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: WommiColors.ink,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.unbounded(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(repositoryProvider).resetEverything();
              await DeviceStorage.clearEmail();
              await LocalBackupStorage.clearAll();
              ref.read(userStateProvider.notifier).hardReset();
              ref.read(onboardingProvider.notifier).reset();

              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil('/landing', (route) => false);
            },
            child: Text(
              'Reset',
              style: GoogleFonts.unbounded(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
