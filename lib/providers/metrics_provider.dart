import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/health_metrics.dart';
import '../models/health_report.dart';
import '../services/firestore_service.dart';

class MetricsProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();

  StreamSubscription<HealthDay>? _metricsSubscription;
  StreamSubscription<List<HealthDay>>? _historySubscription;
  StreamSubscription<List<HealthReport>>? _reportsSubscription;

  HealthDay? _todayMetrics;
  List<HealthDay> _historicalMetrics = [];
  List<HealthReport> _reports = [];

  HealthDay? get todayMetrics => _todayMetrics;
  List<HealthDay> get historicalMetrics => _historicalMetrics;
  List<HealthReport> get reports => _reports;

  /// Called automatically by ProxyProvider in main.dart when auth changes.
  void initialize(User? user) {
    _metricsSubscription?.cancel();
    _historySubscription?.cancel();
    _reportsSubscription?.cancel();

    _todayMetrics = null;
    _historicalMetrics = [];
    _reports = [];

    if (user != null) {
      _metricsSubscription = _db.streamTodayMetrics(user.uid).listen((m) {
        _todayMetrics = m;
        notifyListeners();
      });

      _historySubscription =
          _db.streamHistoricalMetrics(user.uid, 30).listen((m) {
        _historicalMetrics = m;
        notifyListeners();
      });

      _reportsSubscription = _db.streamUserReports(user.uid).listen((r) {
        _reports = r;
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  // ── Convenience write methods ──────────────────────────────────────────────

  Future<void> addWater(String userId, int ml) =>
      _db.updateMetric(userId: userId, waterIntakeMl: ml);

  Future<void> addSteps(String userId, int steps) =>
      _db.updateMetric(userId: userId, steps: steps);

  Future<void> updateMetricDirectly({
    required String userId,
    int? steps,
    int? calories, // caloriesBurned (exercise)
    int? caloriesConsumed,
    int? waterMl,
    int? sleep,
    int? heartRate,
    double? weight,
    int? bpSystolic,
    int? bpDiastolic,
    double? bloodGlucose,
    double? oxygenSaturation,
  }) async {
    await _db.updateMetric(
      userId: userId,
      steps: steps,
      caloriesBurned: calories,
      caloriesConsumed: caloriesConsumed,
      waterIntakeMl: waterMl,
      sleepMinutes: sleep,
      heartRate: heartRate,
      weight: weight,
      bloodPressureSystolic: bpSystolic,
      bloodPressureDiastolic: bpDiastolic,
      bloodGlucose: bloodGlucose,
      oxygenSaturation: oxygenSaturation,
    );
  }

  @override
  void dispose() {
    _metricsSubscription?.cancel();
    _historySubscription?.cancel();
    _reportsSubscription?.cancel();
    super.dispose();
  }
}
