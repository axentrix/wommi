import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/database.dart';
import '../models/charm_rarity.dart';

/// One slot in the album - either a real earned charm, or a not-yet-earned
/// placeholder for a day/kind that's still possible to collect.
class _AlbumSlot {
  final String title;
  final String subtitle;
  final String icon;
  final CharmRarity? rarity;
  final bool earned;

  const _AlbumSlot({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.rarity,
    required this.earned,
  });
}

/// A sticker-album view of every charm the current journey has (or could
/// still) collect: one grid cell per day's ritual charm and per day's game
/// charm, up to [currentDay] - future days aren't real slots yet, the same
/// way they aren't real markers on the map yet. Earned slots show their
/// actual name and rarity; the rest show as blank, greyed-out "?" cards,
/// so the grid also doubles as a completion checklist.
///
/// Charms that don't fit the day/kind pattern (e.g. the once-per-journey
/// pregnancy charm) aren't part of that count - anything else earned is
/// just appended at the end, since there's no "potential" slot for it.
class CharmAlbumGrid extends StatelessWidget {
  final int currentDay;
  final List<CharmsEarnedData> charms;

  const CharmAlbumGrid({
    super.key,
    required this.currentDay,
    required this.charms,
  });

  List<_AlbumSlot> _buildSlots() {
    final byKey = <String, CharmsEarnedData>{
      for (final c in charms) '${c.cycleDay}-${c.charmName}': c,
    };
    final consumedKeys = <String>{};

    final slots = <_AlbumSlot>[];
    final lastDay = currentDay.clamp(0, currentDay);
    for (var day = 1; day <= lastDay; day++) {
      for (final kind in const [
        ('daily_charm', 'Rituals', '🌸'),
        ('game_charm', 'Game', '🎮'),
      ]) {
        final (charmName, subtitle, icon) = kind;
        final key = '$day-$charmName';
        final row = byKey[key];
        consumedKeys.add(key);
        slots.add(_AlbumSlot(
          title: 'Day $day',
          subtitle: subtitle,
          icon: icon,
          rarity: row != null ? CharmRarity.fromName(row.rarity) : null,
          earned: row != null,
        ));
      }
    }

    // Anything earned outside the day/kind pattern above (e.g.
    // 'pregnancy_charm') - always shown, since it was actually collected.
    for (final c in charms) {
      final key = '${c.cycleDay}-${c.charmName}';
      if (consumedKeys.contains(key)) continue;
      slots.add(_AlbumSlot(
        title: 'Day ${c.cycleDay}',
        subtitle: _specialCharmLabel(c.charmName),
        icon: '👑',
        rarity: CharmRarity.fromName(c.rarity),
        earned: true,
      ));
    }

    return slots;
  }

  String _specialCharmLabel(String charmName) {
    switch (charmName) {
      case 'pregnancy_charm':
        return 'Pregnancy';
      default:
        return 'Bonus';
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = _buildSlots();
    if (slots.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CHARM ALBUM',
          style: GoogleFonts.spaceMono(
            fontSize: 10.5,
            letterSpacing: 1.68,
            color: WommiColors.rose,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, i) => _AlbumCell(slot: slots[i]),
        ),
      ],
    );
  }
}

class _AlbumCell extends StatelessWidget {
  final _AlbumSlot slot;

  const _AlbumCell({required this.slot});

  @override
  Widget build(BuildContext context) {
    final rarity = slot.rarity;
    final (background, border) = !slot.earned
        ? (WommiColors.bgSoft, WommiColors.line)
        : switch (rarity!) {
            CharmRarity.legendary => (WommiColors.goldSoft, WommiColors.gold),
            CharmRarity.rare => (WommiColors.lilac, WommiColors.cyan),
            CharmRarity.normal => (Colors.white, WommiColors.line),
          };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: slot.earned ? 1 : 0.5,
            child: Text(
              slot.earned ? slot.icon : '❓',
              style: const TextStyle(fontSize: 26),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            slot.title,
            style: GoogleFonts.unbounded(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: slot.earned ? WommiColors.ink : WommiColors.inkDim,
            ),
          ),
          Text(
            slot.subtitle,
            style: GoogleFonts.inter(
              fontSize: 9.5,
              color: WommiColors.inkDim,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: slot.earned ? border.withOpacity(0.18) : WommiColors.line,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              slot.earned ? rarity!.label : '?',
              style: GoogleFonts.spaceMono(
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                color: slot.earned ? WommiColors.inkDim : WommiColors.inkDim,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
