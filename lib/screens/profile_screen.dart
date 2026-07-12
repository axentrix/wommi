import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/repository_provider.dart';
import '../widgets/edit_cycle_day_dialog.dart';
import '../widgets/edit_conception_dialog.dart';
import '../widgets/journey_completion_dialog.dart';
import '../widgets/pregnancy_win_dialog.dart';
import '../widgets/continue_journey_question_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final onboardingData = ref.watch(onboardingProvider);

    return Container(
      color: WommiColors.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    WommiColors.lilac.withOpacity(0.3),
                    WommiColors.rose.withOpacity(0.2),
                    WommiColors.cyan.withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: WommiColors.line,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  userState.name != null && userState.name!.isNotEmpty
                      ? userState.name![0].toUpperCase()
                      : '👤',
                  style: GoogleFonts.unbounded(
                    fontSize: userState.name != null ? 40 : 48,
                    fontWeight: FontWeight.w800,
                    color: WommiColors.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              userState.name ?? 'No name',
              style: GoogleFonts.unbounded(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: WommiColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            // Email
            Text(
              userState.email ?? '',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: WommiColors.inkDim,
              ),
            ),
            const SizedBox(height: 20),
            // Period started toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: WommiColors.line,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Period started',
                    style: GoogleFonts.unbounded(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WommiColors.ink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: false,
                    activeColor: WommiColors.cyan,
                    onChanged: (value) {
                      if (value) {
                        _showJourneyCompletionDialog(context, ref);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Pregnancy detected toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: WommiColors.line,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Pregnancy detected',
                    style: GoogleFonts.unbounded(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: WommiColors.ink,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: false,
                    activeColor: WommiColors.rose,
                    onChanged: (value) {
                      if (value) {
                        _showPregnancyWinDialog(context, ref);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Journey',
                    value: '${userState.currentJourneyNumber}',
                    icon: '🗺️',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Cycle Day',
                    value: '${userState.currentDay}',
                    icon: '🌸',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Gems',
                    value: '${userState.gemBalance}',
                    icon: '💎',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Streak',
                    value: '${userState.streakDays}',
                    icon: '🔥',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Settings section
            _buildSectionHeader('Your Journey Settings'),
            const SizedBox(height: 12),
            _SettingCard(
              title: 'Cycle Information',
              subtitle: 'Currently on day ${onboardingData.cycleDay} of your cycle',
              onTap: () => _showEditCycleDay(context),
            ),
            const SizedBox(height: 12),
            _SettingCard(
              title: 'Conception Status',
              subtitle: onboardingData.conceptionStatus?.label ?? 'Not set',
              onTap: () => _showEditConception(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.spaceMono(
          fontSize: 10.5,
          letterSpacing: 1.68,
          color: WommiColors.rose,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  void _showEditCycleDay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditCycleDayDialog(),
    );
  }

  void _showEditConception(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const EditConceptionDialog(),
    );
  }

  void _showJourneyCompletionDialog(BuildContext context, WidgetRef ref) {
    final userState = ref.read(userStateProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => JourneyCompletionDialog(
        gemsCollected: userState.gemBalance,
        onStartNewJourney: () async {
          final profileId = userState.profileId;
          if (profileId != null) {
            // Attribute the completed journey to this user so it's kept
            // permanently, even across app restarts or a new journey.
            await ref.read(repositoryProvider).saveJourneyRecord(
                  userProfileId: profileId,
                  journeyNumber: userState.currentJourneyNumber,
                  gemsCollected: userState.gemBalance,
                  startDate: userState.lastOpenedDate ?? DateTime.now(),
                  endDate: DateTime.now(),
                );
          }
          // Clear all ritual completions and charms for the new journey
          await ref.read(repositoryProvider).clearJourneyProgress();
          ref.read(userStateProvider.notifier).completeCurrentJourney();
          if (!context.mounted) return;
          Navigator.pop(context);
          // Navigate to landing screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/landing',
            (route) => false,
          );
        },
      ),
    );
  }

  void _showPregnancyWinDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PregnancyWinDialog(
        onShare: () {
          // Share functionality - disabled for now
          Navigator.pop(context);
          _showContinueJourneyDialog(context, ref);
        },
        onNoThanks: () {
          Navigator.pop(context);
          _showContinueJourneyDialog(context, ref);
        },
      ),
    );
  }

  void _showContinueJourneyDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ContinueJourneyQuestionDialog(
        onContinue: () {
          // Continue journey - go back to home
          Navigator.pop(context);
        },
        onComplete: () async {
          // Complete journey - save and go to achievements
          final userState = ref.read(userStateProvider);
          final profileId = userState.profileId;

          if (profileId != null && userState.gemBalance > 0) {
            await ref.read(repositoryProvider).saveJourneyRecord(
                  userProfileId: profileId,
                  journeyNumber: userState.currentJourneyNumber,
                  gemsCollected: userState.gemBalance,
                  startDate: userState.lastOpenedDate ?? DateTime.now(),
                  endDate: DateTime.now(),
                );
          }

          // Clear progress for next journey
          await ref.read(repositoryProvider).clearJourneyProgress();
          ref.read(userStateProvider.notifier).completeCurrentJourney();

          if (!context.mounted) return;
          Navigator.pop(context);
          // Navigate to achievements screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
          // Switch to achievements tab (tab index 3)
          // Note: This will require updating the home screen to accept initial tab
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: WommiColors.line,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.unbounded(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: WommiColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: WommiColors.inkDim,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: WommiColors.line,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.unbounded(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: WommiColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: WommiColors.inkDim,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: WommiColors.inkDim,
            ),
          ],
        ),
      ),
    );
  }
}
