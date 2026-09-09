import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/repository_provider.dart';
import '../services/device_storage.dart';
import '../services/local_backup_storage.dart';
import '../widgets/start_new_journey_day_dialog.dart';

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
                if (hasExistingJourney) ...[
                  // Primary action: continue the active journey
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                        'Continue Journey',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Secondary action: abandon the active journey and start
                  // a new one - for the SAME profile, so gender/name/email
                  // are already known and never re-asked; only the new
                  // journey's start day needs picking (see
                  // StartNewJourneyDayDialog).
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) => StartNewJourneyDayDialog(
                            onConfirm: (startDay) async {
                              final userState = ref.read(userStateProvider);
                              final profileId = userState.profileId;

                              // Save the current journey regardless of gem
                              // count. This button only appears when
                              // hasExistingJourney is true, so a real journey
                              // number was already assigned - skipping the
                              // save on 0 gems leaves a permanent gap in
                              // journey numbering (e.g. 1, 3, 4 with 2
                              // missing).
                              if (profileId != null) {
                                await ref.read(repositoryProvider).saveJourneyRecord(
                                      userProfileId: profileId,
                                      journeyNumber: userState.currentJourneyNumber,
                                      gemsCollected: userState.gemBalance,
                                      startDate: userState.lastOpenedDate ?? DateTime.now(),
                                      endDate: DateTime.now(),
                                    );
                              }

                              await ref.read(repositoryProvider).clearJourneyProgress();
                              // Carries over gender identity and TTC status/
                              // method from the journey that's ending - see
                              // saveCycleProfileForNewJourney.
                              await ref
                                  .read(repositoryProvider)
                                  .saveCycleProfileForNewJourney(
                                    startDate: DateTime.now()
                                        .subtract(Duration(days: startDay - 1)),
                                    startingCycleDay: startDay,
                                  );
                              ref
                                  .read(userStateProvider.notifier)
                                  .completeCurrentJourney(startDay: startDay);

                              if (!context.mounted) return;
                              Navigator.of(context)
                                  .pushReplacementNamed('/home');
                            },
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: WommiColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(color: WommiColors.line, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Start New Journey',
                        style: GoogleFonts.unbounded(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // No active journey - only option is to start one
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/onboarding-gender');
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
