import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_router.dart';
import 'package:go_router/go_router.dart'; // <--- ADD THIS LINE

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
      appBar: AppBar(
        title: const Text('Patient Detail'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon:
                const Icon(Icons.add_circle_outline, color: AppColors.primary),
            tooltip: 'Add Report',
            onPressed: () =>
                context.push('${AppRoutes.providerAddReport}/$patientUid'),
          ),
        ],
      ),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.person,
                                size: 38, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['username'] ?? 'Unknown',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary)),
                                Text(p['email'] ?? '',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary)),
                                Text('${p['gender'] ?? '–'} · $age yrs',
                                    style: const TextStyle(
                                        color: AppColors.textHint,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statChip('Height', '${h.toStringAsFixed(0)} cm',
                              AppColors.primary),
                          _statChip('Weight', '${w.toStringAsFixed(1)} kg',
                              AppColors.steps),
                          _statChip(
                              'BMI',
                              bmi > 0 ? bmi.toStringAsFixed(1) : '–',
                              bmi > 25 ? AppColors.error : AppColors.success),
                        ],
                      ),
                      if (conditions.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: conditions
                              .map((c) => Chip(
                                    label: Text(c,
                                        style: const TextStyle(fontSize: 12)),
                                    backgroundColor:
                                        AppColors.primary.withAlpha(20),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Today's Metrics
                StreamBuilder<dynamic>(
                  stream: db.streamTodayMetrics(patientUid),
                  builder: (ctx, mSnap) {
                    final m = mSnap.data;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Today's Metrics",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _metricChip('👟', 'Steps', '${m?.steps ?? 0}'),
                              _metricChip(
                                  '💧', 'Water', '${m?.waterIntakeMl ?? 0} ml'),
                              _metricChip('🔥', 'Calories',
                                  '${m?.caloriesBurned ?? 0}'),
                              _metricChip('😴', 'Sleep',
                                  '${((m?.sleepMinutes ?? 0) / 60).toStringAsFixed(1)}h'),
                            ],
                          ),
                          if ((m?.heartRate ?? 0) > 0) ...[
                            const SizedBox(height: 8),
                            Text(
                                'Heart Rate: ${m!.heartRate} bpm  ·  BP: ${m.bloodPressureSystolic}/${m.bloodPressureDiastolic}',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Reports list
                const Text('Reports',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.textPrimary)),
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
                          child: Text('No reports yet. Tap + to add one.',
                              style: TextStyle(color: AppColors.textSecondary)),
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
                              borderRadius: BorderRadius.circular(20)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.description,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(r['title'] ?? 'Report',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary))),
                                  Text(date,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textHint)),
                                ],
                              ),
                              if ((r['notes'] as String? ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(r['notes'] ?? '',
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        height: 1.4)),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      ],
    );
  }

  Widget _metricChip(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 13)),
        Text(label,
            style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }
}
