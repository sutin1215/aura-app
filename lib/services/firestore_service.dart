import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_metrics.dart';
import '../models/health_report.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _getTodayId() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ── Today's Metrics ────────────────────────────────────────────────────────

  Stream<HealthDay> streamTodayMetrics(String userId) {
    final todayId = _getTodayId();
    return _db
        .collection('users')
        .doc(userId)
        .collection('metrics')
        .doc(todayId)
        .snapshots()
        .map((snap) => snap.exists
            ? HealthDay.fromFirestore(snap)
            : HealthDay(id: todayId, date: DateTime.now()));
  }

  Future<void> updateMetric({
    required String userId,
    int? steps,
    int? caloriesBurned,
    int? caloriesConsumed,
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
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('metrics')
        .doc(_getTodayId());

    final Map<String, dynamic> data = {};

    if (steps != null) {
      data['steps'] = FieldValue.increment(steps);
    }
    if (caloriesBurned != null) {
      data['caloriesBurned'] = FieldValue.increment(caloriesBurned);
    }
    if (caloriesConsumed != null) {
      data['caloriesConsumed'] = FieldValue.increment(caloriesConsumed);
    }
    if (waterIntakeMl != null) {
      data['waterIntakeMl'] = FieldValue.increment(waterIntakeMl);
    }
    if (sleepMinutes != null) {
      data['sleepMinutes'] = FieldValue.increment(sleepMinutes);
    }
    if (activeMinutes != null) {
      data['activeMinutes'] = FieldValue.increment(activeMinutes);
    }

    if (heartRate != null) {
      data['heartRate'] = heartRate;
    }
    if (weight != null) {
      data['weight'] = weight;
    }
    if (bloodPressureSystolic != null) {
      data['bloodPressureSystolic'] = bloodPressureSystolic;
    }
    if (bloodPressureDiastolic != null) {
      data['bloodPressureDiastolic'] = bloodPressureDiastolic;
    }
    if (bloodGlucose != null) {
      data['bloodGlucose'] = bloodGlucose;
    }
    if (oxygenSaturation != null) {
      data['oxygenSaturation'] = oxygenSaturation;
    }

    data['date'] = FieldValue.serverTimestamp();
    await docRef.set(data, SetOptions(merge: true));
  }

  // ── Historical Metrics ─────────────────────────────────────────────────────

  Stream<List<HealthDay>> streamHistoricalMetrics(String userId, int daysBack) {
    final cutoff = DateTime.now().subtract(Duration(days: daysBack));
    return _db
        .collection('users')
        .doc(userId)
        .collection('metrics')
        .where('date', isGreaterThanOrEqualTo: cutoff)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => HealthDay.fromFirestore(doc)).toList());
  }

  // ── Reports ────────────────────────────────────────────────────────────────

  Stream<List<HealthReport>> streamUserReports(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('reports')
        .orderBy('dateUploaded', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => HealthReport.fromFirestore(doc)).toList());
  }

  // ── Activities ─────────────────────────────────────────────────────────────

  Future<void> addActivity({
    required String userId,
    required String sportType,
    required int durationMinutes,
    required int caloriesBurned,
    required int stepsAdded,
  }) async {
    final now = DateTime.now();
    final todayId = DateFormat('yyyy-MM-dd').format(now);

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
    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _db
        .collection('users')
        .doc(userId)
        .collection('activities')
        .doc(todayId)
        .collection('entries')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> deleteActivity({
    required String userId,
    required String entryId,
    required int caloriesBurned,
    required int stepsAdded,
    required int durationMinutes,
  }) async {
    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
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

  Future<void> addMeal({
    required String userId,
    required String mealType,
    required String foodName,
    required int calories,
  }) async {
    final now = DateTime.now();
    final todayId = DateFormat('yyyy-MM-dd').format(now);

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

    await updateMetric(userId: userId, caloriesConsumed: calories);
  }

  Stream<List<Map<String, dynamic>>> streamTodayMeals(String userId) {
    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(todayId)
        .collection('entries')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> deleteMeal({
    required String userId,
    required String entryId,
    required int calories,
  }) async {
    final todayId = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await _db
        .collection('users')
        .doc(userId)
        .collection('meals')
        .doc(todayId)
        .collection('entries')
        .doc(entryId)
        .delete();

    await updateMetric(userId: userId, caloriesConsumed: -calories);
  }

  // ── Goals ──────────────────────────────────────────────────────────────────

  Future<void> addGoal({
    required String userId,
    required String name,
    required String metric,
    required double target,
  }) async {
    await _db.collection('users').doc(userId).collection('goals').add({
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
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> deleteGoal({
    required String userId,
    required String goalId,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .doc(goalId)
        .delete();
  }

  // ── Notifications ──────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> streamNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Marks a single notification as read.
  Future<void> markNotificationRead(
      String userId, String notificationId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// Marks every notification as read in a single batch write.
  Future<void> markAllNotificationsRead(String userId) async {
    final snap = await _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Deletes a single notification document.
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

  // ── Appointments ───────────────────────────────────────────────────────────

  Future<void> addAppointment({
    required String userId,
    required String doctorName,
    required DateTime dateTime,
    String note = '',
  }) async {
    await _db.collection('users').doc(userId).collection('appointments').add({
      'doctorName': doctorName,
      'dateTime': Timestamp.fromDate(dateTime),
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamAppointments(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('appointments')
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
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

  // ── Patient-Provider Chat ──────────────────────────────────────────────────

  Future<void> sendMessage({
    required String patientUid,
    required String providerUid,
    required String text,
    required String senderId,
  }) async {
    final chatId = '${patientUid}_$providerUid';
    await _db.collection('chats').doc(chatId).collection('messages').add({
      'text': text,
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamChatMessages({
    required String patientUid,
    required String providerUid,
  }) {
    final chatId = '${patientUid}_$providerUid';
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  // ── Provider helpers ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getPatientProfile(String patientUid) async {
    final doc = await _db.collection('users').doc(patientUid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  /// Stream of patient UIDs assigned to this provider.
  /// Used by ProviderDashboardScreen.
  Stream<List<String>> streamPatientIds(String providerUid) {
    return _db
        .collection('users')
        .where('assignedProviderId', isEqualTo: providerUid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  Future<List<Map<String, dynamic>>> getAssignedPatients(
      String providerUid) async {
    final snap = await _db
        .collection('users')
        .where('assignedProviderId', isEqualTo: providerUid)
        .get();
    return snap.docs.map((d) => {'uid': d.id, ...d.data()}).toList();
  }

  /// Stream of reports for a specific patient.
  /// Used by PatientDetailScreen.
  Stream<List<Map<String, dynamic>>> streamPatientReports(String patientUid) {
    return _db
        .collection('users')
        .doc(patientUid)
        .collection('reports')
        .orderBy('dateUploaded', descending: true)
        .snapshots()
        .map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  /// Saves a text-based report for a patient (no PDF upload needed for demo).
  /// Used by AddReportScreen.
  Future<void> addReport({
    required String patientUid,
    required String providerName,
    required String title,
    String notes = '',
  }) async {
    await _db.collection('users').doc(patientUid).collection('reports').add({
      'title': title,
      'notes': notes,
      'providerName': providerName,
      'dateUploaded': DateTime.now().toIso8601String(),
    });
  }

  /// Links a patient to a provider by writing assignedProviderId on the
  /// patient's user document. Used by SettingsScreen.
  Future<void> linkPatientToProvider({
    required String patientUid,
    required String providerUid,
  }) async {
    // Verify the provider exists first
    final providerDoc = await _db.collection('users').doc(providerUid).get();
    if (!providerDoc.exists) {
      throw Exception('Provider ID not found. Please check and try again.');
    }
    final providerData = providerDoc.data();
    if (providerData?['role'] != 'provider') {
      throw Exception('That ID does not belong to a healthcare provider.');
    }

    await _db.collection('users').doc(patientUid).update({
      'assignedProviderId': providerUid,
    });
  }

  /// Assigns a provider to a patient directly — used by the partner
  /// specialist flow where the providerUid is a trusted hardcoded value.
  Future<void> assignProvider({
    required String patientUid,
    required String providerUid,
  }) async {
    await _db.collection('users').doc(patientUid).update({
      'assignedProviderId': providerUid,
    });
  }
}
