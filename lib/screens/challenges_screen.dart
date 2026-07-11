import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/challenge.dart';
import '../providers/challenges_provider.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';
import '../widgets/win_state_dialog.dart';

class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    // Generate challenges for current day when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userStateProvider);
      ref.read(challengesProvider.notifier).generateChallengesForDay(
            userState.currentDay,
          );
    });
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
    final wasCompleted =
        ref.read(challengesProvider).firstWhere((c) => c.id == challengeId).isCompleted;

    challengesNotifier.toggleChallenge(challengeId);

    // Save to database if being marked complete
    if (!wasCompleted) {
      final repository = ref.read(repositoryProvider);
      await repository.markRitualComplete(userState.currentDay, challengeId);
    }

    // Check if all challenges are now completed
    if (!wasCompleted && challengesNotifier.allCompleted) {
      // Award charm to database
      final repository = ref.read(repositoryProvider);
      await repository.awardCharm(userState.currentDay, 'daily_charm');

      // Add gem to user state
      ref.read(userStateProvider.notifier).addGems(1);

      // Show win dialog after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showWinDialog();
        }
      });
    }
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
          // Challenges list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ChallengeCard(
                    challenge: challenge,
                    onToggle: () => _toggleChallenge(challenge.id),
                  ),
                );
              },
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
