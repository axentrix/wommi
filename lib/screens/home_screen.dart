import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../models/challenge.dart';
import '../models/charm_rarity.dart';
import '../models/onboarding_state.dart';
import '../models/user_state.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';
import '../widgets/app_header_bar.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/journey_map_widget.dart';
import '../widgets/gem_balance_popup.dart';
import '../widgets/ovulation_check_dialog.dart';
import 'challenges_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  // The home header's "Next ritual" card (see _buildMissionCard) - null
  // while loading, and also once every ritual for today is done, in which
  // case the card just doesn't show.
  String? _nextRitualTitle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userState = ref.read(userStateProvider);

      // A cycle day of 0 means onboarding was never actually completed -
      // e.g. the user navigated here directly (URL bar, browser back/
      // forward) without going through the cycle-day picker. Bounce back
      // to landing instead of rendering a broken "Day 0" home screen.
      if (userState.currentDay <= 0) {
        print('[Home] No cycle day set - redirecting to landing/onboarding');
        Navigator.of(context).pushNamedAndRemoveUntil('/landing', (route) => false);
        return;
      }

      // Profile collection normally happens as part of the onboarding
      // Navigator flow (see OnboardingProfileScreen) before the user ever
      // reaches here. This is just a fallback for edge cases - e.g. direct
      // navigation to '/home' with a cycle day already set but no profile.
      print('[Home] Checking profile - hasProfile: ${userState.hasProfile}, name: ${userState.name}, email: ${userState.email}');
      if (!userState.hasProfile) {
        print('[Home] No profile yet - redirecting to profile step');
        Navigator.of(context).pushReplacementNamed('/onboarding-profile');
        return;
      }

      _checkOvulationStatus(userState);
      _loadNextRitual(userState);
    });
  }

  /// Today's first not-yet-completed ritual, shown on the mission card -
  /// re-run whenever the Map tab is reopened (see WommiBottomNavigationBar's
  /// onTap below), since completing a ritual happens on a different tab and
  /// wouldn't otherwise be noticed here.
  Future<void> _loadNextRitual(UserState userState) async {
    final day = userState.currentDay;
    final repository = ref.read(repositoryProvider);
    final completedIds = await repository.getCompletedRitualIdsForDay(day);
    if (!mounted) return;

    final templates = ChallengeTemplates.getChallengesForDay(
      day,
      userState.tracksMenstrualCycle,
    );
    String? nextTitle;
    for (var i = 0; i < templates.length; i++) {
      if (!completedIds.contains('day_${day}_challenge_$i')) {
        nextTitle = templates[i]['title'];
        break;
      }
    }
    setState(() => _nextRitualTitle = nextTitle);
  }

  /// Once-per-launch ovulation check-in. A man or "other" journey doesn't
  /// track its own menstrual cycle at all (see UserState.tracksMenstrualCycle)
  /// and isn't expected to mark ovulation itself, so once day 14 (the
  /// default ovary-phase boundary - see JourneyMapWidget.defaultOvaryDayCount)
  /// arrives without it, just default it there instead of nagging for input
  /// that was never going to come - the toggle to change it to a different
  /// day (or undo it) is still available everywhere it always was, this
  /// just picks a starting value instead of leaving it unmarked forever. A
  /// woman or undefined-gender journey is expected to mark it, so instead
  /// of guessing, this asks - but only once day 18 arrives, well past the
  /// point a real ovulation would typically have happened, so it isn't
  /// asked prematurely.
  void _checkOvulationStatus(UserState userState) {
    // A future-dated mark (ahead of currentDay) isn't real yet - treated as
    // unmarked here too, so a bad value from somewhere else still gets
    // caught by this same check-in instead of silently blocking it forever.
    if (userState.effectiveOvulationDay != null) return;

    final gender = userState.genderIdentity;
    final defaultsSilently =
        gender == GenderIdentity.man || gender == GenderIdentity.other;

    if (defaultsSilently) {
      if (userState.currentDay >= 14) {
        ref.read(userStateProvider.notifier).markOvulationDay(14);
        ref.read(repositoryProvider).setOvulationDay(14);
      }
      return;
    }

    if (userState.currentDay < 18) return;
    showDialog(
      context: context,
      builder: (context) => OvulationCheckDialog(
        currentDay: userState.currentDay,
        onStillWaiting: () => Navigator.pop(context),
        onItStarted: () {
          Navigator.pop(context);
          ref
              .read(userStateProvider.notifier)
              .markOvulationDay(userState.currentDay);
          ref
              .read(repositoryProvider)
              .setOvulationDay(userState.currentDay);
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The cycle day is only ever calculated from the real calendar date at
    // a cold start (splash screen). A user who keeps this tab open/
    // backgrounded across midnight instead of reloading would otherwise
    // see the same day forever - so re-check whenever the app/tab regains
    // focus, same as returning to it the next day would.
    if (state == AppLifecycleState.resumed) {
      _refreshCurrentDay();
    }
  }

  Future<void> _refreshCurrentDay() async {
    final repository = ref.read(repositoryProvider);
    final freshDay = await repository.calculateCurrentCycleDay();
    if (!mounted) return;
    final userState = ref.read(userStateProvider);
    if (freshDay != userState.currentDay) {
      print('[Home] Day changed on resume: ${userState.currentDay} -> $freshDay');
      ref.read(userStateProvider.notifier).updateCurrentDay(freshDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider);

    if (userState.currentDay <= 0) {
      // Avoid flashing broken "Day 0" content while the redirect above
      // (scheduled after the first frame) takes effect.
      return Scaffold(
        backgroundColor: WommiColors.riveBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final header = _buildHeader(userState);

    return Scaffold(
      // Only matters where something doesn't fully cover it - on Home the
      // map (see below) fills the whole SafeArea itself, on every other tab
      // this is what actually shows through the header's own transparent
      // background.
      backgroundColor: _currentIndex == 0 ? WommiColors.riveBg : WommiColors.bg,
      body: SafeArea(
        child: _currentIndex == 0
            // On Home the header (and the mission card) float over the map
            // instead of sitting in their own space above/below it - the
            // header has no background color of its own, so the map's
            // artwork shows through behind it instead of a flat color seam
            // where the two used to meet.
            ? Stack(
                children: [
                  Positioned.fill(child: _buildContent()),
                  Positioned(top: 0, left: 0, right: 0, child: header),
                  if (_nextRitualTitle != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: _buildMissionCard(_nextRitualTitle!),
                    ),
                ],
              )
            : Column(
                children: [
                  header,
                  Expanded(child: _buildContent()),
                ],
              ),
      ),
      bottomNavigationBar: WommiBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh the mission card in case a ritual was just completed on
          // another tab - this State persists across tab switches, so
          // nothing else would notice that on its own.
          if (index == 0) {
            _loadNextRitual(ref.read(userStateProvider));
          }
        },
      ),
    );
  }

  Widget _buildHeader(UserState userState) {
    return AppHeaderBar(
      userState: userState,
      subtitle: _phaseSubtitle(userState),
      onGemsTap: (badgeContext) => _showGemPopup(
        badgeContext,
        userState.gemBalance,
        userState.streakDays,
      ),
    );
  }

  /// A short, punchy phase description for the header subtitle - separate
  /// from CycleDayInfoDialog's more clinical phase names, same underlying
  /// day/ovulation logic though.
  String _phaseSubtitle(UserState userState) {
    if (!userState.tracksMenstrualCycle) {
      return 'Keep up the great work';
    }
    final day = userState.currentDay;
    final ovulationDay = userState.effectiveOvulationDay;
    if (ovulationDay == null) {
      return day <= 5 ? 'Resting and releasing' : 'Ovulation on its way';
    }
    if (day < ovulationDay) return 'Ovulation on its way';
    if (day == ovulationDay) return 'Ovulation day!';
    final daysSinceOvulation = day - ovulationDay;
    if (daysSinceOvulation <= 6) return 'Early luteal phase';
    if (daysSinceOvulation <= 13) return 'Two week wait';
    return 'New cycle coming soon';
  }

  /// The "Next ritual" card floating above the bottom nav on the Map tab -
  /// hidden entirely once today's rituals are all done (see
  /// _loadNextRitual). Tapping it jumps to the Daily Rituals tab.
  Widget _buildMissionCard(String ritualTitle) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: WommiColors.ink.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next ritual',
                    style: GoogleFonts.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: WommiColors.missionLabelPink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    ritualTitle,
                    style: GoogleFonts.unbounded(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.missionTitleDark,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/images/home/chevron_right.png',
              width: 16,
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showGemPopup(BuildContext badgeContext, int gemBalance, int streakDays) async {
    final button = badgeContext.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(badgeContext).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          button.size.bottomLeft(const Offset(0, 8)),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(const Offset(0, 8)),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    // Fetch the real per-charm rarities so the necklace shows actual
    // normal/rare/legendary beads instead of generic gems.
    final charmRows = await ref.read(repositoryProvider).getAllCharms();
    if (!mounted) return;
    final charms = charmRows.map((c) => CharmRarity.fromName(c.rarity)).toList();

    showMenu(
      context: badgeContext,
      color: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      position: position,
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: GemBalancePopupContent(
            gemBalance: gemBalance,
            streakDays: streakDays,
            charms: charms,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return _buildJourneyMap();
      case 1:
        return const ChallengesScreen();
      case 2:
        return const AchievementsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return _buildJourneyMap();
    }
  }

  Widget _buildJourneyMap() {
    // Flat, matching the Figma homepage's solid background - the previous
    // radial lilac highlight looked out of place once this became a dark
    // purple instead of a light cyan.
    return Container(
      color: WommiColors.riveBg,
      child: const JourneyMapWidget(),
    );
  }

  Widget _buildPlaceholder(String title, String icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.unbounded(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: WommiColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: GoogleFonts.mulish(
              fontSize: 11,
              color: WommiColors.inkDim,
            ),
          ),
        ],
      ),
    );
  }
}
