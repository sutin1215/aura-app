import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_router.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientUid;
  const PatientDetailScreen({super.key, required this.patientUid});

  int _age(String? dob) {
    if (dob == null) return 0;
    final birth = DateTime.tryParse(dob);
    if (birth == null) return 0;
    final now = DateTime.now();
    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }

  double _bmi(double h, double w) {
    if (h <= 0 || w <= 0) return 0;
    return w / ((h / 100) * (h / 100));
  }

  @override
  Widget build(BuildContext context) {
    final db = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: db.getPatientProfile(patientUid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final p = snap.data;
          if (p == null) {
            return const Center(child: Text('Patient not found'));
          }

          final age = _age(p['dateOfBirth']);
          final h = (p['height'] ?? 0).toDouble();
          final w = (p['weight'] ?? 0).toDouble();
          final bmi = _bmi(h, w);
          final conditions = List<String>.from(p['healthConditions'] ?? []);
          final name = p['username'] ?? 'Patient';

          return CustomScrollView(
            slivers: [
              // ── Gradient App Bar ───────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.note_add_outlined,
                        color: Colors.white),
                    tooltip: 'Add Report',
                    onPressed: () => context
                        .push('${AppRoutes.providerAddReport}/$patientUid'),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white.withAlpha(40),
                              child: Text(
                                name[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(name,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(p['email'] ?? '',
                                      style: TextStyle(
                                          color: Colors.white.withAlpha(200),
                                          fontSize: 13)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p['gender'] ?? '–'} · $age yrs · ${p['healthConditions'] != null && (p['healthConditions'] as List).isNotEmpty ? (p['healthConditions'] as List).first : 'No conditions'}',
                                    style: TextStyle(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Vitals Row ───────────────────────────────────────
                      Row(
                        children: [
                          _vitalCard('Height', '${h.toStringAsFixed(0)} cm',
                              Icons.height, AppColors.primary),
                          const SizedBox(width: 12),
                          _vitalCard('Weight', '${w.toStringAsFixed(1)} kg',
                              Icons.monitor_weight_outlined, AppColors.steps),
                          const SizedBox(width: 12),
                          _vitalCard(
                            'BMI',
                            bmi > 0 ? bmi.toStringAsFixed(1) : '–',
                            Icons.calculate_outlined,
                            bmi > 30
                                ? AppColors.error
                                : bmi > 25
                                    ? AppColors.warning
                                    : AppColors.success,
                          ),
                        ],
                      ),

                      if (conditions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: conditions
                              .map((c) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withAlpha(15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.error.withAlpha(60)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.health_and_safety,
                                            size: 13, color: AppColors.error),
                                        const SizedBox(width: 4),
                                        Text(c,
                                            style: const TextStyle(
                                                color: AppColors.error,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Today's Metrics ──────────────────────────────────
                      _sectionLabel("Today's Metrics"),
                      const SizedBox(height: 12),
                      StreamBuilder<dynamic>(
                        stream: db.streamTodayMetrics(patientUid),
                        builder: (ctx, mSnap) {
                          final m = mSnap.data;
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withAlpha(5),
                                    blurRadius: 10),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _metricTile('👟', 'Steps',
                                        '${m?.steps ?? 0}', AppColors.steps),
                                    _metricTile(
                                        '💧',
                                        'Water',
                                        '${m?.waterIntakeMl ?? 0} ml',
                                        AppColors.water),
                                    _metricTile(
                                        '🔥',
                                        'Calories',
                                        '${m?.caloriesBurned ?? 0}',
                                        AppColors.calories),
                                    _metricTile(
                                        '😴',
                                        'Sleep',
                                        '${((m?.sleepMinutes ?? 0) / 60).toStringAsFixed(1)}h',
                                        AppColors.sleep),
                                  ],
                                ),
                                if ((m?.heartRate ?? 0) > 0) ...[
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _metricTile(
                                          '❤️',
                                          'Heart Rate',
                                          '${m!.heartRate} bpm',
                                          AppColors.error),
                                      _metricTile(
                                          '🩺',
                                          'Blood Pressure',
                                          '${m.bloodPressureSystolic}/${m.bloodPressureDiastolic}',
                                          AppColors.primary),
                                      if ((m.glucoseLevel ?? 0) > 0)
                                        _metricTile(
                                            '🩸',
                                            'Glucose',
                                            '${m.glucoseLevel} mg/dL',
                                            Colors.orange),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Reports ──────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionLabel('Reports'),
                          TextButton.icon(
                            onPressed: () => context.push(
                                '${AppRoutes.providerAddReport}/$patientUid'),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Report'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: db.streamPatientReports(patientUid),
                        builder: (ctx, rSnap) {
                          final reports = rSnap.data ?? [];
                          if (reports.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.description_outlined,
                                        size: 40, color: AppColors.textHint),
                                    SizedBox(height: 8),
                                    Text('No reports yet',
                                        style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600)),
                                    Text('Tap "Add Report" to create one',
                                        style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Column(
                            children: reports.map((r) {
                              final date = r['dateUploaded'] != null
                                  ? DateFormat('MMM d, yyyy')
                                      .format(DateTime.parse(r['dateUploaded']))
                                  : '';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withAlpha(5),
                                        blurRadius: 8),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.primary.withAlpha(15),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                              Icons.description_outlined,
                                              color: AppColors.primary,
                                              size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            r['title'] ?? 'Report',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                fontSize: 14),
                                          ),
                                        ),
                                        Text(date,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textHint)),
                                      ],
                                    ),
                                    if ((r['notes'] as String? ?? '')
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        r['notes'] ?? '',
                                        style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            height: 1.5,
                                            fontSize: 13),
                                      ),
                                    ],
                                    if ((r['providerName'] as String? ?? '')
                                        .isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'By ${r['providerName']}',
                                        style: const TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 11),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<Map<String, dynamic>?>(
        future: db.getPatientProfile(patientUid),
        builder: (context, snap) {
          final patientName = snap.data?['username'] ?? 'Patient';
          return FloatingActionButton.extended(
            onPressed: () => context.push(Uri(
              path: '${AppRoutes.providerChatPatient}/$patientUid',
              queryParameters: {'name': patientName},
            ).toString()),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: const Text('Message Patient',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary),
      );

  Widget _vitalCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: color)),
            Text(label,
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(String emoji, String label, String value, Color color) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }
}
