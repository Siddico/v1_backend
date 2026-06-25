class HealthDataEntity {
  const HealthDataEntity({
    required this.heartRate,
    required this.bloodPressure,
    required this.temperature,
    required this.weight,
    required this.height,
    required this.date,
    this.oxygenSaturation = 98,
    this.riskScore = 46,
  });

  final int heartRate;
  final String bloodPressure;
  final double temperature;
  final double weight;
  final double height;
  final DateTime date;
  final int oxygenSaturation;
  final double riskScore;

  double get bmi {
    final heightMeters = height / 100.0;
    if (heightMeters == 0) return 0;
    return weight / (heightMeters * heightMeters);
  }

  factory HealthDataEntity.fromJson(Map<String, dynamic> json) {
    return HealthDataEntity(
      heartRate: (json['heartRate'] as num?)?.toInt() ?? 70,
      bloodPressure: json['bloodPressure']?.toString() ?? '120/80',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 36.6,
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      height: (json['height'] as num?)?.toDouble() ?? 170.0,
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now() : DateTime.now(),
      oxygenSaturation: (json['oxygenSaturation'] ?? json['oxygen_saturation'] as num?)?.toInt() ?? 98,
      riskScore: (json['riskScore'] ?? json['risk_score'] ?? json['ai_risk_stroke_rate'] as num?)?.toDouble() ?? 46,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'heartRate': heartRate,
      'bloodPressure': bloodPressure,
      'temperature': temperature,
      'weight': weight,
      'height': height,
      'date': date.toIso8601String(),
      'oxygenSaturation': oxygenSaturation,
      'riskScore': riskScore,
    };
  }
}
