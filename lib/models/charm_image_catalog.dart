import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'charm_rarity.dart';

/// The real charm artwork dropped into `assets/images/journeycharms/<rarity>/`
/// and assets/images/rewardcharms/ - discovered from the asset manifest at
/// startup rather than hardcoded, since the files themselves have arbitrary
/// (often export-tool-generated) names with no charm-specific meaning.
///
/// There's no fixed mapping from a specific cycle day to a specific image -
/// far fewer images exist than the 32-day catalog has slots - so a day's
/// image is picked deterministically by cycling through whichever pool
/// applies (see [journeyCharmImage]/[placeholderImage]/[rewardCharmImage]),
/// meaning the same day always shows the same image but distinct days may
/// repeat one once the pool wraps around.
class CharmImageCatalog {
  CharmImageCatalog._();

  static const _journeyCharmsPrefix = 'assets/images/journeycharms/';
  static const _rewardCharmsPrefix = 'assets/images/rewardcharms/';

  static final Map<CharmRarity, List<String>> _journeyPools = {
    CharmRarity.normal: [],
    CharmRarity.rare: [],
    CharmRarity.legendary: [],
  };
  static List<String> _rewardPool = [];
  static bool _loaded = false;

  static const _rarityFolders = {
    CharmRarity.normal: '1star',
    CharmRarity.rare: '2stars',
    CharmRarity.legendary: '3stars',
  };

  /// Reads the asset manifest once and sorts every discovered charm image
  /// into its pool. Safe to call more than once - later calls are no-ops.
  /// Call before runApp() (see main.dart), same as RiveNative.init().
  static Future<void> load() async {
    if (_loaded) return;
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = manifest.listAssets();

    for (final rarity in CharmRarity.values) {
      final folder = '$_journeyCharmsPrefix${_rarityFolders[rarity]}/';
      final pool =
          allAssets.where((path) => path.startsWith(folder)).toList()..sort();
      _journeyPools[rarity] = pool;
    }

    _rewardPool =
        allAssets.where((path) => path.startsWith(_rewardCharmsPrefix)).toList()
          ..sort();

    _loaded = true;
  }

  static String? _pick(List<String> pool, int day) {
    if (pool.isEmpty) return null;
    return pool[(day - 1) % pool.length];
  }

  /// The image for an earned journey (ritual) charm of [rarity] on [day].
  static String? journeyCharmImage(CharmRarity rarity, int day) {
    return _pick(_journeyPools[rarity] ?? const [], day);
  }

  /// The image an unearned journey charm slot shows (in grayscale, see
  /// CharmAlbumGrid) - always drawn from the normal-rarity pool, since a
  /// day's eventual rarity isn't known until it's actually earned.
  static String? placeholderImage(int day) {
    return _pick(_journeyPools[CharmRarity.normal] ?? const [], day);
  }

  /// The image for an earned mini-game (Rewarded Charms) charm on [day].
  static String? rewardCharmImage(int day) {
    return _pick(_rewardPool, day);
  }
}
