import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/database.dart';
import '../models/charm_catalog.dart';
import '../models/charm_rarity.dart';

/// One slot in the album - either a real earned charm, or a not-yet-earned
/// placeholder for a day/kind that's still possible to collect.
class _AlbumSlot {
  final String name;
  final String dayLabel;
  final String icon;
  final CharmRarity? rarity;
  final bool earned;

  const _AlbumSlot({
    required this.name,
    required this.dayLabel,
    required this.icon,
    required this.rarity,
    required this.earned,
  });
}

/// A sticker-album view of every charm the current journey has (or could
/// still) collect: one grid cell per day's ritual charm and per day's game
/// charm, up to a full default journey (see CharmCatalog) - each one has
/// its own fixed name, not just "Day N". Earned slots show their actual
/// name and rarity (as stars); the rest show as blank, greyed-out "?"
/// cards with the name still hidden, so the grid also doubles as a
/// completion checklist and a bit of a collectible mystery.
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
    final lastDay = currentDay.clamp(
      0,
      CharmCatalog.ritualCharmCount > CharmCatalog.gameCharmCount
          ? CharmCatalog.ritualCharmCount
          : CharmCatalog.gameCharmCount,
    );
    for (var day = 1; day <= lastDay; day++) {
      for (final kind in const [
        ('daily_charm', 'Rituals', '🌸'),
        ('game_charm', 'Game', '🎮'),
      ]) {
        final (charmName, kindLabel, icon) = kind;
        final key = '$day-$charmName';
        final row = byKey[key];
        consumedKeys.add(key);
        final name = charmName == 'daily_charm'
            ? CharmCatalog.ritualCharmName(day)
            : CharmCatalog.gameCharmName(day);
        if (name == null) continue;
        slots.add(_AlbumSlot(
          name: name,
          dayLabel: 'Day $day · $kindLabel',
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
        name: CharmCatalog.specialCharmName(c.charmName),
        dayLabel: 'Day ${c.cycleDay} · Bonus',
        icon: '👑',
        rarity: CharmRarity.fromName(c.rarity),
        earned: true,
      ));
    }

    return slots;
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
            mainAxisSpacing: 14,
            crossAxisSpacing: 10,
            childAspectRatio: 0.72,
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

  static const double _circleSize = 64;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CharmCircle(rarity: slot.rarity, icon: slot.icon, earned: slot.earned),
        const SizedBox(height: 8),
        Text(
          slot.earned ? slot.name : '???',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.unbounded(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: slot.earned ? WommiColors.ink : WommiColors.inkDim,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          slot.dayLabel,
          style: GoogleFonts.inter(
            fontSize: 8.5,
            color: WommiColors.inkDim,
          ),
        ),
        const SizedBox(height: 4),
        _StarRow(rarity: slot.rarity),
      ],
    );
  }
}

/// The charm itself - a rounded circle, styled by rarity the same way a
/// bead on the profile/achievements necklace is (see NecklaceCircle's
/// _CharmBead): gold gradient + glow for legendary, lilac-cyan gradient +
/// glow for rare, plain white/bordered for normal. A not-yet-collected
/// slot is just a flat grey circle with a "?" - its real rarity isn't
/// revealed until it's actually earned.
class _CharmCircle extends StatelessWidget {
  final CharmRarity? rarity;
  final String icon;
  final bool earned;

  const _CharmCircle({
    required this.rarity,
    required this.icon,
    required this.earned,
  });

  static const double _size = _AlbumCell._circleSize;

  @override
  Widget build(BuildContext context) {
    if (!earned || rarity == null) {
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: WommiColors.bgSoft,
          border: Border.all(color: WommiColors.line, width: 1.5),
        ),
        child: Center(
          child: Text('❓', style: TextStyle(fontSize: _size * 0.36)),
        ),
      );
    }

    switch (rarity!) {
      case CharmRarity.legendary:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [WommiColors.gold, Color(0xFFFFF0C4)],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: WommiColors.gold.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Center(
            child: Text(icon, style: TextStyle(fontSize: _size * 0.36)),
          ),
        );
      case CharmRarity.rare:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [WommiColors.lilac, WommiColors.cyan],
            ),
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: WommiColors.cyan.withOpacity(0.35),
                blurRadius: 12,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Center(
            child: Text(icon, style: TextStyle(fontSize: _size * 0.36)),
          ),
        );
      case CharmRarity.normal:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: WommiColors.line, width: 1.5),
          ),
          child: Center(
            child: Text(icon, style: TextStyle(fontSize: _size * 0.36)),
          ),
        );
    }
  }
}

/// Rarity as 1/2/3 filled stars out of 3 (normal/rare/legendary) - empty
/// grey stars for a not-yet-collected slot, since its rarity isn't known
/// until it's earned.
class _StarRow extends StatelessWidget {
  final CharmRarity? rarity;

  const _StarRow({required this.rarity});

  int get _filled => switch (rarity) {
        CharmRarity.legendary => 3,
        CharmRarity.rare => 2,
        CharmRarity.normal => 1,
        null => 0,
      };

  @override
  Widget build(BuildContext context) {
    final color = switch (rarity) {
      CharmRarity.legendary => WommiColors.gold,
      CharmRarity.rare => WommiColors.cyanDark,
      CharmRarity.normal => WommiColors.inkDim,
      null => WommiColors.line,
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isFilled = i < _filled;
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_border_rounded,
          size: 12,
          color: isFilled ? color : WommiColors.line,
        );
      }),
    );
  }
}
