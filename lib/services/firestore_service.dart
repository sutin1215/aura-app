import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_metrics.dart';
import '../models/health_report.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _getTodayId() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ── Today's Metrics ────────────────────────────────────────────────────────

  Stream<HealthDay> streamTodayMetrics(String userId) {
    final String todayId = _getTodayId();
    return _db
        .collection('users')
        .doc(userId)
        .collection('metrics')
        .doc(todayId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return HealthDay.fromFirestore(snapshot);
      } else {
        return HealthDay(id: todayId, date: DateTime.now());
      }
    });
  }

  Future<void> updateMetric({
    required String userId,
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
  }) async {
    final String todayId = _getTodayId();
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('metrics')
        .doc(todayId);

    Map<String, dynamic> data = {};
    if (steps != null) data['steps'] = FieldValue.increment(steps);
    if (caloriesBurned != null) data['caloriesBurned'] = FieldValue.increment(caloriesBurned);
    if (waterIntakeMl != null) data['waterIntakeMl'] = FieldValue.increment(waterIntakeMl);
    if (sleepMinutes != null) data['sleepMinutes'] = FieldValue.increment(sleepMinutes);
    if (activeMinutes != null) data['activeMinutes'] = FieldValue.increment(activeMinutes);
    if (heartRate != null) data['heartRate'] = heartRate;
    if (weight != null) data['weight'] = weight;
    if (bloodPressureSystolic != null) data['bloodPressureSystolic'] = bloodPressureSystolic;
    if (bloodPressureDiastolic != null) data['bloodPressureDiastolic'] = bloodPressureDiastolic;
    if (bloodGlucose != null) data['bloodGlucose'] = bloodGlucose;
    if (oxygenSaturation != null) data['oxygenSaturation'] = oxygenSaturation;
    data['date'] = FieldValue.serverTimestamp();

    await docRef.set(data, SetOptions(merge: true));
  }

  // ── Historical Metrics ─────────────────────────────────────────────────────

  Stream<List<HealthDay>> streamHistoricalMetrics(String userId, int daysBack) {
    final DateTime cutoffDate = DateTime.now().subtract(Duration(days: daysBack));
    return _db
        .collection('users')
        .doc(userId)
        .collection('metrics')
        .where('date', isGreaterThanOrEqualTo: cutoffDate)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => HealthDay.fromFirestore(doc)).toList());
  }

  // ── Reports ────────────────────────────────────────────────────────────────

  Stream<List<HealthReport>> streamUserReports(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('reports')
        .orderBy('dateUploaded', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => HealthReport.fromFirestore(doc)).toList());
  }

  // ── Activities ─────────────────────────────────────────────────────────────

  /// Saves an activity entry and bumps today's steps + calories + activeMinutes
  Future<void> addActivity({
    required String userId,
    required String sportType,
    required int durationMinutes,
    required int caloriesBurned,
    required int stepsAdded,
  }) async {
    final now = DateTime.now();
    final String todayId = DateFormat('yyyy-MM-dd').format(now);

    await _db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(todayId)
        .collection('entries')
        .add({
      'sportType': sportType,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'stepsAdded': stepsAdded,
      'createdAt': Timestamp.fromDate(now),
    });

    await updateMetric(
      userId: userId,
      steps: stepsAdded,
      caloriesBurned: caloriesBurned,
      activeMinutes: durationMinutes,
    );
  }

  Stream<List<Map<String, dynamic>>> streamTodayActivities(String userId) {
    final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(todayId)
        .collection('entries')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> deleteActivity({
    required String userId,
    required String entryId,
    required int caloriesBurned,
    required int stepsAdded,
    required int durationMinutes,
  }) async {
    final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(todayId)
        .collection('entries')
        .doc(entryId)
        .delete();

    await updateMetric(
      userId: userId,
      steps: -stepsAdded,
      caloriesBurned: -caloriesBurned,
      activeMinutes: -durationMinutes,
    );
  }

  // ── Meals ──────────────────────────────────────────────────────────────────

  /// Saves a meal entry and bumps today's caloriesBurned
  Future<void> addMeal({
    required String userId,
    required String mealType,
    required String foodName,
    required int calories,
  }) async {
    final now = DateTime.now();
    final String todayId = DateFormat('yyyy-MM-dd').format(now);

    await _db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(todayId)
        .collection('entries')
        .add({
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'createdAt': Timestamp.fromDate(now),
    });

    await updateMetric(userId: userId, caloriesBurned: calories);
  }

  Stream<List<Map<String, dynamic>>> streamTodayMeals(String userId) {
    final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(todayId)
        .collection('entries')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> deleteMeal({
    required String userId,
    required String entryId,
    required int calories,
  }) async {
    final String todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(todayId)
        .collection('entries')
        .doc(entryId)
        .delete();

    await updateMetric(userId: userId, caloriesBurned: -calories);
  }
  // ── Goals ──────────────────────────────────────────────────────────────────

  Future<void> addGoal({
    required String userId,
    required String name,
    required String metric,
    required double target,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .add({
      'name': name,
      'metric': metric,
      'target': target,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamGoals(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> deleteGoal({required String userId, required String goalId}) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  Future<void> addNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': title,
      'body': body,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> markNotificationRead({
    required String userId,
    required String notificationId,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final batch = _db.batch();
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
  // ── Provider Methods ───────────────────────────────────────────────────────

  /// Get a patient's full profile document
  Future<Map<String, dynamic>?> getPatientProfile(String patientUid) async {
    final doc = await _db.collection('users').doc(patientUid).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...doc.data()!};
  }

  /// Stream the list of patient UIDs assigned to a provider
  Stream<List<String>> streamPatientIds(String providerUid) {
    return _db
        .collection('users')
        .doc(providerUid)
        .snapshots()
        .map((doc) => List<String>.from(doc.data()?['assignedPatientIds'] ?? []));
  }

  /// Provider adds a text report for a patient
  Future<void> addReport({
    required String patientUid,
    required String providerName,
    required String title,
    required String notes,
  }) async {
    await _db
        .collection('users')
        .doc(patientUid)
        .collection('reports')
        .add({
      'title': title,
      'notes': notes,
      'providerName': providerName,
      'dateUploaded': DateTime.now().toIso8601String(),
    });
  }

  /// Stream all reports for a patient (used by both patient Analytics + provider portal)
  Stream<List<Map<String, dynamic>>> streamPatientReports(String patientUid) {
    return _db
        .collection('users')
        .doc(patientUid)
        .collection('reports')
        .orderBy('dateUploaded', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Patient enters provider UID to link themselves
  Future<void> linkPatientToProvider({
    required String patientUid,
    required String providerUid,
  }) async {
    // Verify provider exists
    final providerDoc = await _db.collection('users').doc(providerUid).get();
    if (!providerDoc.exists || providerDoc.data()?['role'] != 'provider') {
      throw Exception('Provider not found. Please check the Provider ID.');
    }

    final batch = _db.batch();

    // Set assignedProviderId on patient
    batch.update(_db.collection('users').doc(patientUid), {
      'assignedProviderId': providerUid,
    });

    // Add patientUid to provider's assignedPatientIds
    batch.update(_db.collection('users').doc(providerUid), {
      'assignedPatientIds': FieldValue.arrayUnion([patientUid]),
    });

    await batch.commit();
  }

  // ── Appointments ───────────────────────────────────────────────────────────

  Future<void> addAppointment({
    required String userId,
    required String doctorName,
    required DateTime dateTime,
    required String note,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .add({
      'doctorName': doctorName,
      'dateTime': dateTime.toIso8601String(),
      'note': note,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamAppointments(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> deleteAppointment({
    required String userId,
    required String appointmentId,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .doc(appointmentId)
        .delete();
  }
}
