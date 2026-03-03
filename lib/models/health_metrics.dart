import 'package:cloud_firestore/cloud_firestore.dart';

class HealthDay {
  final String id; // Typically the date string 'YYYY-MM-DD'
  final DateTime date;
  final int steps;
  final int caloriesBurned;
  final int waterIntakeMl;
  final int sleepMinutes;
  
  // New Vitals (Phase 6)
  final int heartRate;
  final double weight;
  final int bloodPressureSystolic;
  final int bloodPressureDiastolic;
  final double bloodGlucose;
  final double oxygenSaturation;
  final int activeMinutes;

  HealthDay({
    required this.id,
    required this.date,
    this.steps = 0,
    this.caloriesBurned = 0,
    this.waterIntakeMl = 0,
    this.sleepMinutes = 0,
    this.heartRate = 0,
    this.weight = 0.0,
    this.bloodPressureSystolic = 0,
    this.bloodPressureDiastolic = 0,
    this.bloodGlucose = 0.0,
    this.oxygenSaturation = 0.0,
    this.activeMinutes = 0,
  });

  // Serialization from Firestore
  factory HealthDay.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return HealthDay(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      steps: data['steps'] ?? 0,
      caloriesBurned: data['caloriesBurned'] ?? 0,
      waterIntakeMl: data['waterIntakeMl'] ?? 0,
      sleepMinutes: data['sleepMinutes'] ?? 0,
      heartRate: data['heartRate'] ?? 0,
      weight: (data['weight'] ?? 0.0).toDouble(),
      bloodPressureSystolic: data['bloodPressureSystolic'] ?? 0,
      bloodPressureDiastolic: data['bloodPressureDiastolic'] ?? 0,
      bloodGlucose: (data['bloodGlucose'] ?? 0.0).toDouble(),
      oxygenSaturation: (data['oxygenSaturation'] ?? 0.0).toDouble(),
      activeMinutes: data['activeMinutes'] ?? 0,
    );
  }

  // Serialization to Firestore
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'steps': steps,
      'caloriesBurned': caloriesBurned,
      'waterIntakeMl': waterIntakeMl,
      'sleepMinutes': sleepMinutes,
      'heartRate': heartRate,
      'weight': weight,
      'bloodPressureSystolic': bloodPressureSystolic,
      'bloodPressureDiastolic': bloodPressureDiastolic,
      'bloodGlucose': bloodGlucose,
      'oxygenSaturation': oxygenSaturation,
      'activeMinutes': activeMinutes,
    };
  }

  // Utility to copy with new values immutably
  HealthDay copyWith({
    int? steps,
    int? caloriesBurned,
    int? waterIntakeMl,
    int? sleepMinutes,
    int? heartRate,
    double? weight,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? bloodGlucose,
    double? oxygenSaturation,
    int? activeMinutes,
  }) {
    return HealthDay(
      id: id,
      date: date,
      steps: steps ?? this.steps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      heartRate: heartRate ?? this.heartRate,
      weight: weight ?? this.weight,
      bloodPressureSystolic: bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic: bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      bloodGlucose: bloodGlucose ?? this.bloodGlucose,
      oxygenSaturation: oxygenSaturation ?? this.oxygenSaturation,
      activeMinutes: activeMinutes ?? this.activeMinutes,
    );
  }
}
