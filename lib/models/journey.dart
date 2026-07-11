class Journey {
  final int journeyNumber;
  final int gemsCollected;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  Journey({
    required this.journeyNumber,
    required this.gemsCollected,
    required this.startDate,
    this.endDate,
    this.isActive = false,
  });

  Journey copyWith({
    int? journeyNumber,
    int? gemsCollected,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Journey(
      journeyNumber: journeyNumber ?? this.journeyNumber,
      gemsCollected: gemsCollected ?? this.gemsCollected,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'journeyNumber': journeyNumber,
      'gemsCollected': gemsCollected,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      journeyNumber: json['journeyNumber'],
      gemsCollected: json['gemsCollected'],
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? false,
    );
  }
}
