import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../widgets/bottom_navigation_bar.dart';
import '../widgets/profile_collection_dialog.dart';
import '../widgets/journey_map_widget.dart';
import 'challenges_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Show profile collection dialog if profile is not complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = ref.read(userStateProvider);
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
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider);

    return Scaffold(
      backgroundColor: WommiColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(userState.currentDay, userState.gemBalance),
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

  Widget _buildHeader(int currentDay, int gemBalance) {
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
          // Gem balance
          Container(
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
        ],
      ),
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
