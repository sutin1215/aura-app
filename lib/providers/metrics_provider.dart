import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/health_metrics.dart';
import '../models/health_report.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MetricsProvider extends ChangeNotifier {
  final FirestoreService _db = FirestoreService();
  StreamSubscription<HealthDay>? _metricsSubscription;
  
  HealthDay? _todayMetrics;
  HealthDay? get todayMetrics => _todayMetrics;

  List<HealthDay> _historicalMetrics = [];
  List<HealthDay> get historicalMetrics => _historicalMetrics;

  List<HealthReport> _reports = [];
  List<HealthReport> get reports => _reports;

  StreamSubscription<List<HealthDay>>? _historySubscription;
  StreamSubscription<List<HealthReport>>? _reportsSubscription;

  // Call this when the user logs in to start listening
  void initialize(User? user) {
    _metricsSubscription?.cancel();
    _historySubscription?.cancel();
    _reportsSubscription?.cancel();
    
    _todayMetrics = null;
    _historicalMetrics = [];
    _reports = [];

    if (user != null) {
      // Listen to today's metrics
      _metricsSubscription = _db.streamTodayMetrics(user.uid).listen((metrics) {
        _todayMetrics = metrics;
        notifyListeners();
      });

      // Listen to last 30 days of metrics for analytics
      _historySubscription = _db.streamHistoricalMetrics(user.uid, 30).listen((metrics) {
        _historicalMetrics = metrics;
        notifyListeners();
      });

      // Listen to reports
      _reportsSubscription = _db.streamUserReports(user.uid).listen((reports) {
        _reports = reports;
        notifyListeners();
      });
    }
  }

  @override
  void dispose() {
    _metricsSubscription?.cancel();
    _historySubscription?.cancel();
    _reportsSubscription?.cancel();
    super.dispose();
  }

  // Helper methods to increment data via UI
  Future<void> addWater(String userId, int ml) async {
    await _db.updateMetric(userId: userId, waterIntakeMl: ml);
  }

  Future<void> addSteps(String userId, int steps) async {
    await _db.updateMetric(userId: userId, steps: steps);
  }

  Future<void> updateMetricDirectly({
    required String userId,
    int? steps,
    int? calories,
    int? waterMl,
    int? sleep,
  }) async {
    await _db.updateMetric(
      userId: userId,
      steps: steps,
      caloriesBurned: calories,
      waterIntakeMl: waterMl,
      sleepMinutes: sleep,
    );
  }
}
