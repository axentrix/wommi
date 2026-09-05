import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/daily_game.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/cycle_day_info_dialog.dart';
import '../widgets/games/lucky_wheel_game.dart';
import '../widgets/games/pinata_game.dart';
import '../widgets/games/bubble_pop_game.dart';
import '../widgets/games/avatar_customization_game.dart';
import '../widgets/games/room_customization_game.dart';
import 'challenges_screen.dart';

/// A plain cross-fade for entering/exiting the full-screen game - the
/// zoom-in preview it replaces was itself just a placeholder for the real
/// Rive camera move, so a simple fade keeps that same "not the final
/// polish" honesty rather than a directional slide that implies more than
/// it is.
Route<void> dailyGameRoute(int day) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) =>
        DailyGameScreen(day: day),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
  );
}

/// Full-screen mini-game opened by tapping a day marker on the journey map -
/// replaces the old "zoom into the map" preview. The day's info dialog
/// (phase description, missions, ovulation/period toggles) still opens on
/// top of it, same as before, just as a dismissable overlay above the game
/// instead of above the zoomed map - dismissing it reveals the game
/// underneath rather than leaving this screen.
///
/// Each game widget under widgets/games/ is a placeholder standing in for
/// a real Rive scene, and awards a second, independent charm on top of
/// whatever the day's 3 rituals already give.
class DailyGameScreen extends ConsumerStatefulWidget {
  final int day;

  const DailyGameScreen({super.key, required this.day});

  @override
  ConsumerState<DailyGameScreen> createState() => _DailyGameScreenState();
}

class _DailyGameScreenState extends ConsumerState<DailyGameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDayInfo());
  }

  Future<void> _showDayInfo() async {
    final day = widget.day;
    final userState = ref.read(userStateProvider);
    final conceptionStatus = ref.read(onboardingProvider).conceptionStatus;
    final isCompleted = userState.completedDays.contains(day);

    await showDialog(
      context: context,
      builder: (context) => CycleDayInfoDialog(
        day: day,
        conceptionStatus: conceptionStatus,
        isCompleted: isCompleted,
        isInProgress: !isCompleted && userState.inProgressDays.contains(day),
        isCurrent: day == userState.currentDay,
        isFuture: day > userState.currentDay,
        onOpenMissions: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChallengesScreen(day: day),
            ),
          );
        },
      ),
    );
  }

  /// Locks the day's game out after this attempt, win or lose - a day only
  /// gets one play. Triggers a rebuild via userStateProvider, which is what
  /// swaps in _buildAlreadyPlayed() below.
  void _onPlayed() {
    ref.read(userStateProvider.notifier).markDailyGamePlayed(widget.day);
  }

  /// Awards the day's second charm if this attempt won.
  void _onWin() {
    ref.read(userStateProvider.notifier).markDailyGameComplete(widget.day);
    if (!mounted) return;

    ref.read(userStateProvider.notifier).addGems(1);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: WommiColors.deepBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Row(
          children: [
            const Text('💎', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Charm collected! +1 gem',
                style: GoogleFonts.unbounded(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame(DailyGame game) {
    switch (game) {
      case DailyGame.luckyWheel:
        return LuckyWheelGame(onWin: _onWin, onPlayed: _onPlayed);
      case DailyGame.pinata:
        return PinataGame(onWin: _onWin, onPlayed: _onPlayed);
      case DailyGame.bubblePop:
        return BubblePopGame(onWin: _onWin, onPlayed: _onPlayed);
      case DailyGame.avatarCustomization:
        return AvatarCustomizationGame(onWin: _onWin, onPlayed: _onPlayed);
      case DailyGame.roomCustomization:
        return RoomCustomizationGame(onWin: _onWin, onPlayed: _onPlayed);
    }
  }

  /// Shown instead of the real game once this day's single attempt is used
  /// up - win or lose, a day only gets one play (see
  /// UserState.dailyGamePlayedDays).
  Widget _buildAlreadyPlayed(DailyGame game) {
    final won = ref.watch(userStateProvider).dailyGameCompletedDays.contains(widget.day);
    return Container(
      color: WommiColors.bgSoft,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(game.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Icon(Icons.lock_outline, size: 28, color: WommiColors.inkDim),
            const SizedBox(height: 16),
            Text(
              '${game.label} already played',
              style: GoogleFonts.unbounded(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: WommiColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                won
                    ? 'You already collected this day\'s charm from it.'
                    : 'No luck this time - each day only gets one go.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: WommiColors.inkDim,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = dailyGameForDay(widget.day);
    final alreadyPlayed =
        ref.watch(userStateProvider).dailyGamePlayedDays.contains(widget.day);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: alreadyPlayed ? _buildAlreadyPlayed(game) : _buildGame(game),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: _RoundIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Center(
                  child: GestureDetector(
                    onTap: _showDayInfo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: WommiColors.cyan,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: WommiColors.cyan.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline,
                              size: 15, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Day ${widget.day} details',
                            style: GoogleFonts.unbounded(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.92),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: WommiColors.ink),
      ),
    );
  }
}
