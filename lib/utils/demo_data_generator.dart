import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DemoDataGenerator {
  static Future<void> populateGoldenPath(String userId) async {
    final db = FirebaseFirestore.instance;
    final now = DateTime.now();

    // 1. Generate 7 days of realistic metrics (fl_chart data)
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      final isToday = i == 0;
      // Adds a realistic fluctuation to the data
      final steps = isToday ? 6420 : 7000 + (date.weekday * 600) % 4000;
      final calBurned = isToday ? 450 : 400 + (date.weekday * 50) % 300;
      final calConsumed = isToday ? 1200 : 1800 + (date.day * 100) % 600;
      final water = isToday ? 1500 : 1500 + (date.day * 200) % 1000;
      final sleep = isToday ? 380 : 400 + (date.day * 30) % 120;
      final hr = 70 + (date.day % 12);
      final sys = 115 + (date.day % 8);
      final dia = 75 + (date.day % 6);

      await db
          .collection('users')
          .doc(userId)
          .collection('metrics')
          .doc(dateStr)
          .set({
        'date': Timestamp.fromDate(date),
        'steps': steps,
        'caloriesBurned': calBurned,
        'caloriesConsumed': calConsumed,
        'waterIntakeMl': water,
        'sleepMinutes': sleep,
        'heartRate': hr,
        'weight': 71.5 - (i * 0.15), // Smooth downward trend for weight loss
        'bloodPressureSystolic': sys,
        'bloodPressureDiastolic': dia,
        'bloodGlucose': 95.0,
        'oxygenSaturation': 98.0,
        'activeMinutes': 30 + (date.day % 25),
      }, SetOptions(merge: true));
    }

    // 2. Add Meals (Diet Log)
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    final mealsRef = db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(todayStr)
        .collection('entries');
    final existingMeals = await mealsRef.limit(1).get();
    if (existingMeals.docs.isEmpty) {
      await mealsRef.add({
        'mealType': 'Breakfast',
        'foodName': 'Avocado Toast & Coffee',
        'calories': 420,
        'createdAt':
            Timestamp.fromDate(DateTime(now.year, now.month, now.day, 8, 15)),
      });
      await mealsRef.add({
        'mealType': 'Lunch',
        'foodName': 'Grilled Chicken Salad',
        'calories': 550,
        'createdAt':
            Timestamp.fromDate(DateTime(now.year, now.month, now.day, 12, 45)),
      });
    }

    // 3. Add Activities
    final actRef = db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(todayStr)
        .collection('entries');
    final existingActs = await actRef.limit(1).get();
    if (existingActs.docs.isEmpty) {
      await actRef.add({
        'sportType': 'Running',
        'durationMinutes': 30,
        'caloriesBurned': 320,
        'stepsAdded': 4000,
        'createdAt':
            Timestamp.fromDate(DateTime(now.year, now.month, now.day, 7, 0)),
      });
    }

    // 4. Add Active Goals
    final goalsRef = db.collection('users').doc(userId).collection('goals');
    final existingGoals = await goalsRef.limit(1).get();
    if (existingGoals.docs.isEmpty) {
      await goalsRef.add({
        'name': 'Daily Steps',
        'metric': 'steps',
        'target': 10000.0,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await goalsRef.add({
        'name': 'Hydration Goal',
        'metric': 'waterIntakeMl',
        'target': 2500.0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    // 5. Add some unread notifications
    final notifRef =
        db.collection('users').doc(userId).collection('notifications');
    final existingNotifs = await notifRef.limit(1).get();
    if (existingNotifs.docs.isEmpty) {
      await notifRef.add({
        'title': 'Hydration Reminder 💧',
        'body': "You're halfway to your daily water goal! Keep it up.",
        'isRead': false,
        'createdAt': DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
      });
      await notifRef.add({
        'title': 'Great Job! 🏃',
        'body': 'You burned 320 kcal during your morning run.',
        'isRead': true,
        'createdAt':
            DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      });
    }

    // 6. Add an upcoming appointment
    final apptRef =
        db.collection('users').doc(userId).collection('appointments');
    final existingAppts = await apptRef.limit(1).get();
    if (existingAppts.docs.isEmpty) {
      await apptRef.add({
        'doctorName': 'Dr. Sarah Kang',
        'dateTime': DateTime.now()
            .add(const Duration(days: 2, hours: 4))
            .toIso8601String(),
        'note': 'Routine check-up & blood test review',
      });
    }
  }
}
