/// The mini-game shown full-screen when a day's marker is tapped, in place
/// of the old "zoom into the map" preview. Each of these is a placeholder
/// for a real Rive scene - see the individual widgets under
/// lib/widgets/games/ - and each awards a second, independent charm on top
/// of whatever the day's 3 rituals already give.
enum DailyGame {
  luckyWheel('Lucky Wheel', '🎡'),
  pinata('Piñata Smash', '🪅'),
  bubblePop('Bubble Pop', '🫧'),
  avatarCustomization('Avatar Studio', '🧑‍🎨'),
  roomCustomization('Room Makeover', '🏡');

  const DailyGame(this.label, this.emoji);
  final String label;
  final String emoji;
}

/// Which game a given cycle day opens. Temporarily always the Lucky Wheel -
/// the other 4 aren't ready to ship yet - rather than the eventual fixed
/// rotation through all 5 (so the same day always reopens the same game
/// rather than reshuffling on every visit).
DailyGame dailyGameForDay(int day) {
  return DailyGame.luckyWheel;
}
