import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;
  final String sportType;
  final int durationMinutes;
  final int caloriesBurned;
  final int stepsAdded;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.sportType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.stepsAdded,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sportType': sportType,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'stepsAdded': stepsAdded,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Activity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Activity(
      id: doc.id,
      sportType: data['sportType'] ?? 'Exercise',
      durationMinutes: data['durationMinutes'] ?? 0,
      caloriesBurned: data['caloriesBurned'] ?? 0,
      stepsAdded: data['stepsAdded'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
