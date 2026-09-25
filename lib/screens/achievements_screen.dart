import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../data/database.dart';
import '../models/charm_catalog.dart';
import '../models/charm_image_catalog.dart';
import '../models/charm_rarity.dart';
import '../providers/user_state_provider.dart';
import '../providers/repository_provider.dart';
import '../widgets/necklace_wheel.dart';
import 'journey_collection_screen.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  List<CharmsEarnedData>? _currentCharmRows;
  // The separate, lifetime Rewarded Charms album (mini-game wins) - null
  // until loaded, empty once loaded with nothing won yet.
  List<CharmsEarnedData>? _rewardedCharmRows;
  // Keyed by Journey.cycleProfileId, one entry per past journey that has
  // one (see Journey.cycleProfileId for why some don't).
  Map<int, List<CharmsEarnedData>> _pastJourneyCharmRows = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCharms());
  }

  Future<void> _loadCharms() async {
    final repository = ref.read(repositoryProvider);
    final pastIds = ref
        .read(userStateProvider)
        .journeyHistory
        .map((j) => j.cycleProfileId)
        .whereType<int>()
        .toSet()
        .toList();

    final results = await Future.wait([
      repository.getAllCharms(),
      repository.getAllGameCharms(),
      ...pastIds.map((id) => repository.getCharmsForCycleProfile(id)),
    ]);
    if (!mounted) return;

    setState(() {
      _currentCharmRows = results[0];
      _rewardedCharmRows = results[1];
      _pastJourneyCharmRows = {
        for (var i = 0; i < pastIds.length; i++) pastIds[i]: results[i + 2],
      };
    });
  }

  /// The current journey's charms, in the order they were earned - the
  /// necklace wheel's fixed bottom-center-then-alternate layout (see
  /// NecklaceWheel) is driven by this order, not by day number or rarity.
  List<NecklaceWheelCharm> _necklaceCharms() {
    final rows = [...?_currentCharmRows]
      ..sort((a, b) => a.earnedAt.compareTo(b.earnedAt));

    return rows.map((c) {
      switch (c.charmName) {
        case 'daily_charm':
          return NecklaceWheelCharm(
            imagePath: CharmImageCatalog.journeyCharmImage(
              CharmRarity.fromName(c.rarity),
              c.cycleDay,
            ),
            fallbackEmoji: '🌸',
          );
        case 'game_charm':
          return NecklaceWheelCharm(
            imagePath: CharmImageCatalog.rewardCharmImage(c.cycleDay),
            fallbackEmoji: '🎮',
          );
        default:
          return const NecklaceWheelCharm(fallbackEmoji: '👑');
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateProvider);
    final hasCurrentJourney = userState.currentDay > 0;
    final pastJourneys = userState.journeyHistory;

    return Container(
      color: WommiColors.riveBg,
      child: Column(
        children: [
          if (hasCurrentJourney)
            NecklaceWheel(charms: _necklaceCharms()),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: ListView(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Achievements',
                        style: GoogleFonts.unbounded(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Bonus Gems - the lifetime Rewarded Charms collection.
                  if (_rewardedCharmRows != null) ...[
                    _AchievementCard(
                      title: 'Bonus Gems',
                      isBonus: true,
                      badgeValue: '${_rewardedCharmRows!.length}',
                      badgeLabel:
                          _rewardedCharmRows!.length == 1 ? 'Gem' : 'Gems',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => JourneyCollectionScreen(
                            title: 'Bonus Gems',
                            charms: _rewardedCharmRows!,
                            isRewarded: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // Current journey (in progress).
                  if (hasCurrentJourney) ...[
                    Builder(builder: (context) {
                      final ritualCount = _currentCharmRows
                              ?.where((c) => c.charmName == 'daily_charm')
                              .length ??
                          0;
                      return _AchievementCard(
                        title: 'Journey ${userState.currentJourneyNumber}',
                        statusText: 'In Progress',
                        statusColor: WommiColors.achievementPink,
                        badgeColor: WommiColors.achievementPink,
                        badgeValue:
                            '$ritualCount/${CharmCatalog.ritualCharmCount}',
                        badgeLabel: ritualCount == 1 ? 'Gem' : 'Gems',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => JourneyCollectionScreen(
                              title: 'Journey ${userState.currentJourneyNumber}',
                              charms: _currentCharmRows ?? const [],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                  // Past journeys, most recent first.
                  ...pastJourneys.reversed.map((journey) {
                    final charms = journey.cycleProfileId != null
                        ? _pastJourneyCharmRows[journey.cycleProfileId]
                        : null;
                    final ritualCount = charms
                            ?.where((c) => c.charmName == 'daily_charm')
                            .length ??
                        journey.gemsCollected;
                    final dateFormatter = DateFormat('MMM d, yyyy');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AchievementCard(
                        title: 'Journey ${journey.journeyNumber}',
                        statusText: 'Completed on '
                            '${dateFormatter.format(journey.endDate ?? journey.startDate)}',
                        statusColor: WommiColors.achievementGrey,
                        badgeColor: WommiColors.achievementPurple,
                        badgeValue: '$ritualCount',
                        badgeLabel: ritualCount == 1 ? 'Gem' : 'Gems',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => JourneyCollectionScreen(
                              title: 'Journey ${journey.journeyNumber}',
                              charms: charms ?? const [],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (!hasCurrentJourney && pastJourneys.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            const Text('🌸', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            Text(
                              'No journeys yet',
                              style: GoogleFonts.unbounded(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start your first journey to begin collecting charms',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.mulish(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One journey/bonus summary row (see the Figma achievements design): a
/// title + status line on the left, a round "badge" with the gem count on
/// the right, and a chevron. The Bonus Gems card inverts the palette (solid
/// pink card, white badge) instead of a white card with a colored badge.
class _AchievementCard extends StatelessWidget {
  final String title;
  final String? statusText;
  final Color? statusColor;
  final bool isBonus;
  final Color badgeColor;
  final String badgeValue;
  final String badgeLabel;
  final VoidCallback onTap;

  const _AchievementCard({
    required this.title,
    this.statusText,
    this.statusColor,
    this.isBonus = false,
    this.badgeColor = WommiColors.achievementPink,
    required this.badgeValue,
    required this.badgeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isBonus ? Colors.white : WommiColors.missionTitleDark;
    final chevronColor = isBonus ? Colors.white : WommiColors.inkDim;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isBonus ? WommiColors.achievementPink : Colors.white,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.unbounded(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                    ),
                  ),
                  if (statusText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      statusText!,
                      style: GoogleFonts.mulish(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isBonus ? Colors.white : badgeColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    badgeValue,
                    style: GoogleFonts.unbounded(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isBonus ? WommiColors.achievementPink : Colors.white,
                    ),
                  ),
                  Text(
                    badgeLabel,
                    style: GoogleFonts.mulish(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isBonus ? WommiColors.achievementPink : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 16, color: chevronColor),
          ],
        ),
      ),
    );
  }
}
