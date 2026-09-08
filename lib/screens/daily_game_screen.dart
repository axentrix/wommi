import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/daily_game.dart';
import '../providers/user_state_provider.dart';
import '../providers/onboarding_provider.dart';
import '../providers/repository_provider.dart';
import '../models/charm_rarity.dart';
import '../widgets/cycle_day_info_dialog.dart';
import '../widgets/game_win_dialog.dart';
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

/// Full-screen mini-game pushed on top of the journey map after choosing
/// "Play daily game" from a day's info dialog (see
/// JourneyMapWidget._showDayInfoDialog) - so backing out of this screen
/// lands back on the map. The same info dialog can still be reopened from
/// here via the "Day X details" button, for reference while playing.
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
  // Captured once when this screen opens, rather than watched reactively -
  // the whole point of onPlayed/markDailyGamePlayed is to lock the game out
  // on the *next* visit, not to yank the interactive game out from under
  // the player mid-attempt the moment it fires (which is exactly what
  // watching it live did: the win/lose result never got a chance to show
  // before this screen swapped to the locked view).
  late final bool _alreadyPlayedOnOpen;

  @override
  void initState() {
    super.initState();
    _alreadyPlayedOnOpen =
        ref.read(userStateProvider).dailyGamePlayedDays.contains(widget.day);
  }

  /// Opened via the "Day X details" button while the game is already on
  /// screen - so unlike the same dialog shown from the map
  /// (JourneyMapWidget._showDayInfoDialog), "Play daily game" here just
  /// closes the dialog to reveal the game already running behind it, and
  /// "Complete daily rituals" backs all the way out to the map before
  /// pushing the rituals screen, so backing out of *that* lands on the map
  /// too instead of on this game screen.
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
          final navigator = Navigator.of(context);
          navigator.pop(); // close dialog
          navigator.pop(); // close this game screen, back to the map
          navigator.push(
            MaterialPageRoute(
              builder: (context) => ChallengesScreen(day: day),
            ),
          );
        },
        onPlayGame: () => Navigator.pop(context),
      ),
    );
  }

  /// Records that this day's single attempt is used up, win or lose - takes
  /// effect the *next* time this day's game screen is opened (see
  /// _alreadyPlayedOnOpen), not immediately.
  void _onPlayed() {
    ref.read(userStateProvider.notifier).markDailyGamePlayed(widget.day);
  }

  /// Awards the day's second, independent charm if this attempt won -
  /// persisted the same way a ritual charm is (see
  /// ChallengesScreen._awardCharmIfNeeded), just under its own 'game_charm'
  /// name so the two never collide on the same day. Without this, the gem
  /// count shown by the Achievements necklace (which counts rows in the
  /// charms table) would fall behind the balance shown in the header
  /// (which counts every addGems call, rituals and games alike).
  Future<void> _onWin() async {
    ref.read(userStateProvider.notifier).markDailyGameComplete(widget.day);

    final repository = ref.read(repositoryProvider);
    if (!await repository.hasCharmForDay(widget.day, charmName: 'game_charm')) {
      await repository.awardCharm(widget.day, 'game_charm');
    }
    if (!mounted) return;

    ref.read(userStateProvider.notifier).addGems(1);
    final game = dailyGameForDay(widget.day);
    showDialog(
      context: context,
      builder: (context) => GameWinDialog(
        gameName: game.label,
        gemBalance: ref.read(userStateProvider).gemBalance,
        // Game charms always award at normal rarity for now (see
        // _onWin's awardCharm call above, which doesn't pass one) -
        // rarity theming is still wired through so it's ready if that
        // ever changes.
        rarity: CharmRarity.normal,
        gemEmoji: game.emoji,
        onContinue: () => Navigator.of(context).pop(),
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
    final won = ref.read(userStateProvider).dailyGameCompletedDays.contains(widget.day);
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _alreadyPlayedOnOpen
                ? _buildAlreadyPlayed(game)
                : _buildGame(game),
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
