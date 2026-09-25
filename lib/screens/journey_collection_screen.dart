import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../data/database.dart';
import '../widgets/charm_album_grid.dart';

/// A journey's (or the lifetime Rewarded Charms') full collection, opened
/// from a card on AchievementsScreen. Purely functional for now - reuses
/// the existing album grids as-is; its own visual design is still TBD.
class JourneyCollectionScreen extends StatelessWidget {
  final String title;
  final List<CharmsEarnedData> charms;
  final bool isRewarded;

  const JourneyCollectionScreen({
    super.key,
    required this.title,
    required this.charms,
    this.isRewarded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WommiColors.bg,
      appBar: AppBar(
        backgroundColor: WommiColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: WommiColors.ink),
        title: Text(
          title,
          style: GoogleFonts.unbounded(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: WommiColors.ink,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: isRewarded
              ? RewardedCharmsGrid(charms: charms)
              : CharmAlbumGrid(charms: charms),
        ),
      ),
    );
  }
}
