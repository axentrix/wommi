import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/profile_collection_dialog.dart';
import '../widgets/journey_map_widget.dart';
import '../widgets/gem_balance_popup.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

      // Show profile collection dialog if profile is not complete
      print('[Home] Checking profile - hasProfile: ${userState.hasProfile}, name: ${userState.name}, email: ${userState.email}');
      if (!userState.hasProfile) {
        print('[Home] Showing profile collection dialog');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const ProfileCollectionDialog(),
        );
      }
    });
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
        backgroundColor: WommiColors.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: WommiColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(
              userState.currentDay,
              userState.gemBalance,
              userState.streakDays,
            ),
            // Main content area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WommiBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHeader(int currentDay, int gemBalance, int streakDays) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current day
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CYCLE',
                style: GoogleFonts.spaceMono(
                  fontSize: 9.5,
                  letterSpacing: 1.33,
                  color: WommiColors.inkDim,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Day $currentDay',
                style: GoogleFonts.unbounded(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: WommiColors.ink,
                ),
              ),
            ],
          ),
          // Gem balance - tap to see the necklace mini dashboard
          Builder(
            builder: (badgeContext) => GestureDetector(
              onTap: () =>
                  _showGemPopup(badgeContext, gemBalance, streakDays),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: WommiColors.goldSoft,
                  border: Border.all(
                    color: WommiColors.gold,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Text(
                      '💎',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$gemBalance',
                      style: GoogleFonts.unbounded(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: WommiColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGemPopup(BuildContext badgeContext, int gemBalance, int streakDays) {
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
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.2,
          colors: [
            WommiColors.lilac.withOpacity(0.3),
            WommiColors.bg,
          ],
        ),
      ),
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
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: WommiColors.inkDim,
            ),
          ),
        ],
      ),
    );
  }
}
