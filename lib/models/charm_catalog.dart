/// A fixed pool of named charms - one for every day's ritual and one for
/// every day's mini-game, sized to a full default journey (32 days, see
/// JourneyMapWidget.defaultOvaryDayCount + tubeStepSlots +
/// defaultUterusDayCount = 14 + 5 + 13). Real per-charm artwork will
/// eventually replace the plain names/emoji this stands in for; the fixed
/// size and per-day lookup are already final, so that swap won't need any
/// structural change here.
class CharmCatalog {
  static const int ritualCharmCount = 32;
  static const int gameCharmCount = 32;

  /// Names for days 1..32's ritual charm, in order.
  static const List<String> _ritualNames = [
    'Bright Hope',
    'Gentle Dawn',
    'Soft Petal',
    'Golden Bloom',
    'Silver Moon',
    'Rosy Glow',
    'Quiet Wish',
    'Warm Ember',
    'Tender Bud',
    'Radiant Star',
    'Calm Tide',
    'Blooming Heart',
    'Whispering Breeze',
    'Velvet Dusk',
    'Amber Spark',
    'Crystal Dew',
    'Misty Meadow',
    'Sunny Bloom',
    'Moonlit Feather',
    'Starry Whisper',
    'Pearl Blossom',
    'Coral Dawn',
    'Ivory Petal',
    'Serene Brook',
    'Sweet Aurora',
    'Secret Lotus',
    'Hidden Willow',
    'Gleaming Cloud',
    'Shimmering Grove',
    'Lucky Comet',
    'Wild Fern',
    'Dreamy Nest',
  ];

  /// Names for days 1..32's mini-game charm, in order.
  static const List<String> _gameNames = [
    'Playful Spark',
    'Cozy Ember',
    'Twinkling Star',
    'Blushing Rose',
    'Frosty Dew',
    'Glowing Lantern',
    'Merry Chime',
    'Dewy Meadow',
    'Sparkling Tide',
    'Peaceful Vale',
    'Joyful Melody',
    'Dawning Ray',
    'Drifting Cloud',
    'Floating Feather',
    'Wandering Breeze',
    'Gilded Halo',
    'Opal Mist',
    'Rustic Nest',
    'Vivid Bloom',
    'Faded Petal',
    'Painted Dawn',
    'Fleeting Wish',
    'Blissful Song',
    'Cheerful Sprout',
    'Delicate Vine',
    'Elegant Wave',
    'Fragrant Willow',
    'Graceful Wing',
    'Luminous Prism',
    'Mellow Harbor',
    'Nostalgic Lullaby',
    'Placid Spring',
  ];

  static String? ritualCharmName(int day) =>
      day >= 1 && day <= ritualCharmCount ? _ritualNames[day - 1] : null;

  static String? gameCharmName(int day) =>
      day >= 1 && day <= gameCharmCount ? _gameNames[day - 1] : null;

  /// A name for a charm outside the day/kind pattern (e.g. the
  /// once-per-journey pregnancy charm).
  static String specialCharmName(String charmName) {
    switch (charmName) {
      case 'pregnancy_charm':
        return 'Miracle Bloom';
      default:
        return 'Mystery Charm';
    }
  }
}
