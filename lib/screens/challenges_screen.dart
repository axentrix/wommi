import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/challenge.dart';
import '../providers/challenges_provider.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';
import '../widgets/win_state_dialog.dart';
import '../widgets/challenge_completion_dialog.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    // Generate challenges for current day when screen loads, restoring
    // completion state so progress survives navigating away and back
    // (challenges are now completed one at a time, not all on one page).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userState = ref.read(userStateProvider);
      final repository = ref.read(repositoryProvider);
      final completedIds = await repository.getCompletedRitualIdsForDay(
        userState.currentDay,
      );
      if (!mounted) return;
      ref.read(challengesProvider.notifier).generateChallengesForDay(
            userState.currentDay,
            completedIds: completedIds,
          );

      // All rituals may already be complete from a previous visit whose
      // award never fired (e.g. the user navigated away before it could).
      // Catch up on the reward here so "all complete" never shows with 0
      // gems.
      final awarded = await _awardCharmIfNeeded();
      if (awarded && mounted) _showWinDialog();
    });
  }

  /// Awards the day's charm/gem exactly once, independent of whether this
  /// widget is still mounted by the time it resolves. Safe to call more
  /// than once - it's a no-op if today's charm was already awarded.
  /// Returns whether it was actually awarded just now.
  Future<bool> _awardCharmIfNeeded() async {
    final challengesNotifier = ref.read(challengesProvider.notifier);
    if (challengesNotifier.totalCount == 0) return false;
    if (challengesNotifier.completedCount != challengesNotifier.totalCount) {
      return false;
    }

    final userState = ref.read(userStateProvider);
    final repository = ref.read(repositoryProvider);
    if (await repository.hasCharmForDay(userState.currentDay)) return false;

    await repository.awardCharm(userState.currentDay, 'daily_charm');
    ref.read(userStateProvider.notifier).addGems(1);
    return true;
  }

  void _showWinDialog() {
    final userState = ref.read(userStateProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WinStateDialog(
        currentDay: userState.currentDay,
        gemBalance: userState.gemBalance,
        streakDays: userState.streakDays,
        onContinue: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _toggleChallenge(String challengeId) async {
    final challengesNotifier = ref.read(challengesProvider.notifier);
    final userState = ref.read(userStateProvider);
    final challenge = ref.read(challengesProvider).firstWhere((c) => c.id == challengeId);
    final wasCompleted = challenge.isCompleted;

    if (wasCompleted) return; // Don't untoggle

    challengesNotifier.toggleChallenge(challengeId);

    // Save to database
    final repository = ref.read(repositoryProvider);
    await repository.markRitualComplete(userState.currentDay, challengeId);

    final completedCount = challengesNotifier.completedCount;
    final totalCount = challengesNotifier.totalCount;
    final justCompletedAll = completedCount == totalCount;

    // Award the charm/gem as soon as we know the day is complete, rather
    // than waiting on the delayed dialog below - that way the reward is
    // granted even if the user navigates away before the dialog would show.
    if (justCompletedAll) {
      await _awardCharmIfNeeded();
    }

    // Show dialog after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      if (justCompletedAll) {
        _showWinDialog();
      } else {
        // Individual challenge complete - show simple completion dialog
        _showChallengeCompletionDialog(challenge.title, completedCount, totalCount);
      }
    });
  }

  void _showChallengeCompletionDialog(String title, int completed, int total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChallengeCompletionDialog(
        challengeTitle: title,
        completedCount: completed,
        totalCount: total,
        onContinue: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challenges = ref.watch(challengesProvider);
    final userState = ref.watch(userStateProvider);
    final challengesNotifier = ref.watch(challengesProvider.notifier);

    if (challenges.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final phaseName = ChallengeTemplates.getPhaseNameForDay(userState.currentDay);
    final completedCount = challengesNotifier.completedCount;
    final totalCount = challengesNotifier.totalCount;

    return Container(
      color: WommiColors.bg,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CYCLE DAY ${userState.currentDay}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10.5,
                    letterSpacing: 1.68,
                    color: WommiColors.rose,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  phaseName,
                  style: GoogleFonts.unbounded(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: WommiColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Progress ring hero
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 6),
            child: Row(
              children: [
                // Big progress ring
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      startAngle: -1.5708,
                      colors: [
                        WommiColors.cyan,
                        WommiColors.cyan,
                        WommiColors.line,
                        WommiColors.line,
                      ],
                      stops: [
                        0.0,
                        completedCount / totalCount,
                        completedCount / totalCount,
                        1.0,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$completedCount/$totalCount',
                            style: GoogleFonts.unbounded(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: WommiColors.ink,
                            ),
                          ),
                          Text(
                            'TODAY',
                            style: GoogleFonts.spaceMono(
                              fontSize: 8,
                              color: WommiColors.inkDim,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Caption
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completedCount == totalCount
                            ? 'All done for today!'
                            : completedCount > 0
                                ? 'Almost there'
                                : 'Start your rituals',
                        style: GoogleFonts.unbounded(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WommiColors.ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        completedCount == totalCount
                            ? 'You\'ve completed all rituals. Amazing work!'
                            : 'Complete ${totalCount - completedCount} more ${totalCount - completedCount == 1 ? 'ritual' : 'rituals'} to earn your gem.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: WommiColors.inkDim,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Current challenge (only show next uncompleted)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                child: () {
                  // Find next uncompleted challenge or show completion message
                  final nextChallenge = challenges.firstWhere(
                    (c) => !c.isCompleted,
                    orElse: () => challenges.last,
                  );

                  if (completedCount == totalCount) {
                    // All done - show completion message
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '✨',
                          style: TextStyle(fontSize: 64),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'All rituals complete!',
                          style: GoogleFonts.unbounded(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: WommiColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Come back tomorrow for new rituals',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: WommiColors.inkDim,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  }

                  return _ChallengeCard(
                    challenge: nextChallenge,
                    onToggle: () => _toggleChallenge(nextChallenge.id),
                  );
                }(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onToggle;

  const _ChallengeCard({
    required this.challenge,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: challenge.isCompleted ? Color(0xFFBFEBD6) : WommiColors.line,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(18),
        gradient: challenge.isCompleted
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF1FBF6),
                  Colors.white,
                ],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: WommiColors.ink.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: WommiColors.bgSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                challenge.icon,
                style: const TextStyle(fontSize: 19),
              ),
            ),
          ),
          const SizedBox(width: 13),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: GoogleFonts.unbounded(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: WommiColors.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  challenge.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: WommiColors.inkDim,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF8EB),
                    border: Border.all(
                      color: WommiColors.goldSoft,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '+1 Gem',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: Color(0xFFB9822E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action button
          if (challenge.isCompleted)
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WommiColors.sage,
                border: Border.all(
                  color: WommiColors.sage,
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text(
                  '✓',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: onToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: WommiColors.cyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 8,
                shadowColor: WommiColors.cyan.withOpacity(0.4),
              ),
              child: Text(
                'Start',
                style: GoogleFonts.unbounded(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
