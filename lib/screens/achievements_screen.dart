import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import '../providers/user_state_provider.dart';
import '../models/journey.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    final hasCurrentJourney = userState.currentDay > 0;
    final pastJourneys = userState.journeyHistory;

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
                  'YOUR JOURNEYS',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10.5,
                    letterSpacing: 1.68,
                    color: WommiColors.rose,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Achievements',
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
          // Journey cards
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
              children: [
                // Current journey card (in progress)
                if (hasCurrentJourney)
                  _CurrentJourneyCard(
                    journeyNumber: userState.currentJourneyNumber,
                    gemsCollected: userState.gemBalance,
                    currentDay: userState.currentDay,
                  ),
                // Past journey cards
                ...pastJourneys.reversed.map((journey) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PastJourneyCard(journey: journey),
                  );
                }).toList(),
                // Empty state if no journeys
                if (!hasCurrentJourney && pastJourneys.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        children: [
                          Text(
                            '🌸',
                            style: TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No journeys yet',
                            style: GoogleFonts.unbounded(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: WommiColors.ink,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start your first journey to begin collecting charms',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: WommiColors.inkDim,
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
        ],
      ),
    );
  }
}

class _CurrentJourneyCard extends StatelessWidget {
  final int journeyNumber;
  final int gemsCollected;
  final int currentDay;

  const _CurrentJourneyCard({
    required this.journeyNumber,
    required this.gemsCollected,
    required this.currentDay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WommiColors.cyan.withOpacity(0.1),
            WommiColors.lilac.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: WommiColors.cyan,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Necklace circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: WommiColors.cyan,
                width: 3,
              ),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                // Gems arranged in circle
                ..._buildNecklaceGems(gemsCollected),
                // Center text
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$gemsCollected',
                        style: GoogleFonts.unbounded(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: WommiColors.ink,
                        ),
                      ),
                      Text(
                        gemsCollected == 1 ? 'gem' : 'gems',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          color: WommiColors.inkDim,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'Journey $journeyNumber',
            style: GoogleFonts.unbounded(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: WommiColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: WommiColors.cyan.withOpacity(0.15),
              border: Border.all(
                color: WommiColors.cyan,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              'IN PROGRESS • Day $currentDay',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: WommiColors.cyanDark,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Prompt
          Text(
            'Collect the charms for your necklace',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: WommiColors.inkDim,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNecklaceGems(int count) {
    if (count == 0) return [];

    final maxVisible = 12;
    final gemsToShow = count > maxVisible ? maxVisible : count;
    final List<Widget> gems = [];
    final radius = 35.0;

    for (int i = 0; i < gemsToShow; i++) {
      final angle = (i / maxVisible) * 2 * math.pi - (math.pi / 2);
      final x = radius * (i % 2 == 0 ? 1.0 : 0.85) * math.cos(angle);
      final y = radius * (i % 2 == 0 ? 1.0 : 0.85) * math.sin(angle);

      gems.add(
        Positioned(
          left: 50 + x - 6,
          top: 50 + y - 6,
          child: Text(
            '💎',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    return gems;
  }
}

class _PastJourneyCard extends StatelessWidget {
  final Journey journey;

  const _PastJourneyCard({required this.journey});

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d, yyyy');
    final duration = journey.endDate != null
        ? journey.endDate!.difference(journey.startDate).inDays
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: WommiColors.line,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: WommiColors.ink.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Necklace circle (smaller)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: WommiColors.gold,
                width: 2.5,
              ),
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  WommiColors.goldSoft.withOpacity(0.3),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${journey.gemsCollected}',
                    style: GoogleFonts.unbounded(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: WommiColors.ink,
                    ),
                  ),
                  Text(
                    journey.gemsCollected == 1 ? 'gem' : 'gems',
                    style: GoogleFonts.spaceMono(
                      fontSize: 7,
                      color: WommiColors.inkDim,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Journey info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Journey ${journey.journeyNumber}',
                  style: GoogleFonts.unbounded(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: WommiColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Completed ${dateFormatter.format(journey.endDate ?? journey.startDate)}',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: WommiColors.inkDim,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: WommiColors.goldSoft.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$duration ${duration == 1 ? 'day' : 'days'}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 9,
                      color: Color(0xFFB9822E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
