class Journey {
  final int journeyNumber;
  final int gemsCollected;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  // The CycleProfiles row this journey earned its charms under - lets its
  // charm album still be fetched (via WommiRepository.getCharmsForCycleProfile)
  // after the journey is over. Null for journeys completed before this
  // existed, which have no charm album to show.
  final int? cycleProfileId;

  Journey({
    required this.journeyNumber,
    required this.gemsCollected,
    required this.startDate,
    this.endDate,
    this.isActive = false,
    this.cycleProfileId,
  });

  Journey copyWith({
    int? journeyNumber,
    int? gemsCollected,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? cycleProfileId,
  }) {
    return Journey(
      journeyNumber: journeyNumber ?? this.journeyNumber,
      gemsCollected: gemsCollected ?? this.gemsCollected,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      cycleProfileId: cycleProfileId ?? this.cycleProfileId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'journeyNumber': journeyNumber,
      'gemsCollected': gemsCollected,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'cycleProfileId': cycleProfileId,
    };
  }

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      journeyNumber: json['journeyNumber'],
      gemsCollected: json['gemsCollected'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? false,
      cycleProfileId: json['cycleProfileId'],
    );
  }
}
