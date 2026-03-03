import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String id;
  final String mealType; // Breakfast, Lunch, Dinner, Snacks
  final String foodName;
  final int calories;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Meal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meal(
      id: doc.id,
      mealType: data['mealType'] ?? 'Snacks',
      foodName: data['foodName'] ?? 'Food',
      calories: data['calories'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
