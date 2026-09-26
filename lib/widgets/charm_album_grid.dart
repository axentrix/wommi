import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/database.dart';
import '../models/charm_catalog.dart';
import '../models/charm_image_catalog.dart';
import '../models/charm_rarity.dart';

/// One slot in the album - either a real earned charm, or a not-yet-earned
/// placeholder for a day/kind that's still possible to collect.
class _AlbumSlot {
  final String name;
  // The real charm artwork (see CharmImageCatalog), if one was available to
  // assign to this slot. Falls back to [icon] (a plain emoji) when null -
  // always true for specials like the pregnancy charm, which have no
  // dedicated art pool, and possible in general if the image pool was
  // empty for whatever reason.
  final String? imagePath;
  final String icon;
  final CharmRarity? rarity;
  final bool earned;

  const _AlbumSlot({
    required this.name,
    this.imagePath,
    required this.icon,
    required this.rarity,
    required this.earned,
  });
}

/// A sticker-album view of every charm a journey has (or could still)
/// collect from its daily rituals, up to a full default journey (see
/// CharmCatalog) - each day has its own fixed charm name, not just "Day N".
/// Earned slots show their actual name and rarity (as stars); the rest show
/// as blank, greyed-out "?" cards with the name still hidden, so the grid
/// also doubles as a completion checklist and a bit of a collectible
/// mystery.
///
/// Mini-game charms are deliberately excluded here even if present in
/// [charms] - those live in the separate, lifetime RewardedCharmsGrid
/// instead (see that class), since they aren't tied to a fixed per-journey
/// slot the way ritual charms are. The once-per-journey pregnancy charm
/// (or anything else outside the day/ritual pattern) isn't part of that
/// fixed count either - it's just appended at the end, since there's no
/// "potential" slot for it.
class CharmAlbumGrid extends StatelessWidget {
  final List<CharmsEarnedData> charms;

  const CharmAlbumGrid({
    super.key,
    required this.charms,
  });

  List<_AlbumSlot> _buildSlots() {
    final byDay = <int, CharmsEarnedData>{
      for (final c in charms)
        if (c.charmName == 'daily_charm') c.cycleDay: c,
    };

    // Always the full catalog, not just up to currentDay - the album's
    // total is meant to reflect every ritual charm that can ever be
    // collected, so it stays fixed across the whole journey instead of
    // growing as more days are reached.
    final slots = <_AlbumSlot>[];
    for (var day = 1; day <= CharmCatalog.ritualCharmCount; day++) {
      final name = CharmCatalog.ritualCharmName(day);
      if (name == null) continue;
      final row = byDay[day];
      final rarity = row != null ? CharmRarity.fromName(row.rarity) : null;
      slots.add(_AlbumSlot(
        name: name,
        imagePath: rarity != null
            ? CharmImageCatalog.journeyCharmImage(rarity, day)
            : CharmImageCatalog.placeholderImage(day),
        icon: '🌸',
        rarity: rarity,
        earned: row != null,
      ));
    }

    // Anything earned outside the daily-ritual pattern above (e.g.
    // 'pregnancy_charm') - always shown, since it was actually collected.
    // 'game_charm' is excluded here too (see class doc).
    for (final c in charms) {
      if (c.charmName == 'daily_charm' || c.charmName == 'game_charm') {
        continue;
      }
      slots.add(_AlbumSlot(
        name: CharmCatalog.specialCharmName(c.charmName),
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
          style: GoogleFonts.mulish(
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
            mainAxisSpacing: 8,
            crossAxisSpacing: 10,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, i) => _AlbumCell(slot: slots[i]),
        ),
      ],
    );
  }
}

/// The separate, lifetime album of mini-game charms - one running
/// collection across every journey ever played, not reset when a journey
/// ends and not scoped to any single one (unlike CharmAlbumGrid). Unlike
/// that album, there are no placeholder slots: a mini-game win isn't tied
/// to a fixed day/kind schedule the way a ritual charm is, so this only
/// ever shows what's actually been won, growing one cell at a time.
class RewardedCharmsGrid extends StatelessWidget {
  final List<CharmsEarnedData> charms;

  const RewardedCharmsGrid({
    super.key,
    required this.charms,
  });

  @override
  Widget build(BuildContext context) {
    if (charms.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REWARDED CHARMS',
            style: GoogleFonts.mulish(
              fontSize: 10.5,
              letterSpacing: 1.68,
              color: WommiColors.rose,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Win a daily mini-game to start collecting these.',
            style: GoogleFonts.mulish(
              fontSize: 12.5,
              color: WommiColors.inkDim,
              height: 1.4,
            ),
          ),
        ],
      );
    }

    final slots = charms
        .map((c) => _AlbumSlot(
              name: CharmCatalog.gameCharmName(c.cycleDay) ?? 'Mystery Charm',
              imagePath: CharmImageCatalog.rewardCharmImage(c.cycleDay),
              icon: '🎮',
              rarity: CharmRarity.fromName(c.rarity),
              earned: true,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REWARDED CHARMS',
          style: GoogleFonts.mulish(
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
            mainAxisSpacing: 8,
            crossAxisSpacing: 10,
            childAspectRatio: 0.92,
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
        _CharmCircle(
          rarity: slot.rarity,
          imagePath: slot.imagePath,
          icon: slot.icon,
          earned: slot.earned,
        ),
        const SizedBox(height: 6),
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
        const SizedBox(height: 4),
        _StarRow(rarity: slot.rarity),
      ],
    );
  }
}

// Standard luminance-preserving grayscale matrix - used to desaturate a
// not-yet-earned slot's artwork instead of hiding it behind a generic "?"
// (see _CharmCircle).
const List<double> _grayscaleMatrix = [
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

/// The charm itself - a transparent rounded box, styled by rarity: a gold
/// border + glow for legendary, a lilac-cyan border + glow for rare, a
/// plain bordered box for normal - framing the real charm artwork (see
/// CharmImageCatalog) rather than sitting on a filled/gradient background.
/// A not-yet-collected slot shows that same artwork grayed out and dimmed
/// instead of hidden outright, since its real rarity isn't revealed until
/// it's earned - falling back to a plain "?" only if no artwork was
/// available at all.
class _CharmCircle extends StatelessWidget {
  final CharmRarity? rarity;
  final String? imagePath;
  final String icon;
  final bool earned;

  const _CharmCircle({
    required this.rarity,
    required this.imagePath,
    required this.icon,
    required this.earned,
  });

  static const double _size = _AlbumCell._circleSize;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(16));

  Widget _art(BuildContext context, {required bool grayscale}) {
    final path = imagePath;
    if (path == null) {
      return Center(
        child: Text(icon, style: TextStyle(fontSize: _size * 0.36)),
      );
    }
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final image = Image.asset(
      path,
      width: _size,
      height: _size,
      fit: BoxFit.cover,
      // The source art (especially the reward charms) is far higher
      // resolution than a 64-logical-pixel box needs - decoding at
      // roughly display size instead of full size keeps memory sane.
      cacheWidth: (_size * devicePixelRatio).round(),
      cacheHeight: (_size * devicePixelRatio).round(),
    );
    return ClipRRect(
      borderRadius: _radius,
      child: grayscale
          ? Opacity(
              opacity: 0.55,
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
                child: image,
              ),
            )
          : image,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!earned || rarity == null) {
      return Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          borderRadius: _radius,
          color: Colors.transparent,
          border: Border.all(color: WommiColors.line, width: 1.5),
        ),
        child: _art(context, grayscale: true),
      );
    }

    switch (rarity!) {
      case CharmRarity.legendary:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            borderRadius: _radius,
            color: Colors.transparent,
            border: Border.all(color: WommiColors.gold, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: WommiColors.gold.withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: _art(context, grayscale: false),
        );
      case CharmRarity.rare:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            borderRadius: _radius,
            color: Colors.transparent,
            border: Border.all(color: WommiColors.cyan, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: WommiColors.cyan.withValues(alpha: 0.35),
                blurRadius: 12,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: _art(context, grayscale: false),
        );
      case CharmRarity.normal:
        return Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            borderRadius: _radius,
            color: Colors.transparent,
            border: Border.all(color: WommiColors.line, width: 1.5),
          ),
          child: _art(context, grayscale: false),
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
