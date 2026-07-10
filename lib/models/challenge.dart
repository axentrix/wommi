class Challenge {
  final String id;
  final String icon;
  final String title;
  final String description;
  final bool isCompleted;
  final int day;

  Challenge({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.day,
  });

  Challenge copyWith({
    String? id,
    String? icon,
    String? title,
    String? description,
    bool? isCompleted,
    int? day,
  }) {
    return Challenge(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      day: day ?? this.day,
    );
  }
}

// Challenge templates for different cycle phases
class ChallengeTemplates {
  static List<Map<String, String>> getChallengesForDay(int day) {
    // Days 1-5: Menstruation - Rest & Release
    if (day >= 1 && day <= 5) {
      return [
        {
          'icon': '🌙',
          'title': 'Moon Water Blessing',
          'description': 'Place a glass of water under moonlight (or by a window). Sip it mindfully in the morning.',
        },
        {
          'icon': '🫧',
          'title': 'Womb Rest Breath',
          'description': 'Five slow belly breaths, one hand resting gently over your womb space.',
        },
        {
          'icon': '🪶',
          'title': 'Release Journal',
          'description': 'Write one line about something you\'re ready to let go of this cycle.',
        },
      ];
    }
    // Days 6-13: Follicular - Ground & Awaken
    else if (day >= 6 && day <= 13) {
      return [
        {
          'icon': '🌱',
          'title': 'Morning Intention',
          'description': 'Set one small intention for today. Speak it aloud or write it down.',
        },
        {
          'icon': '💧',
          'title': 'Hydration Ritual',
          'description': 'Drink a full glass of water with gratitude for nourishing your body.',
        },
        {
          'icon': '🌸',
          'title': 'Body Gratitude',
          'description': 'Name three things your body did well today, no matter how small.',
        },
      ];
    }
    // Days 14-16: Ovulation - Bloom & Connect
    else if (day >= 14 && day <= 16) {
      return [
        {
          'icon': '✨',
          'title': 'Ovulation Celebration',
          'description': 'Honor this powerful moment in your cycle with a moment of stillness.',
        },
        {
          'icon': '🌺',
          'title': 'Creative Expression',
          'description': 'Do something creative for 5 minutes - draw, dance, sing, or write.',
        },
        {
          'icon': '💝',
          'title': 'Connection Moment',
          'description': 'Send a loving message to someone who matters to you.',
        },
      ];
    }
    // Days 17+: Luteal - Nurture & Wait
    else {
      return [
        {
          'icon': '🕯️',
          'title': 'Gentle Movement',
          'description': 'Five minutes of gentle stretching or walking in fresh air.',
        },
        {
          'icon': '🍵',
          'title': 'Warm Comfort',
          'description': 'Prepare a warm drink and savor it slowly, feeling its warmth.',
        },
        {
          'icon': '📖',
          'title': 'Evening Reflection',
          'description': 'Note one kind thing you did for yourself today.',
        },
      ];
    }
  }

  static String getPhaseNameForDay(int day) {
    if (day >= 1 && day <= 5) return 'Rest & Release';
    if (day >= 6 && day <= 13) return 'Ground & Awaken';
    if (day >= 14 && day <= 16) return 'Bloom & Connect';
    return 'Nurture & Wait';
  }
}
