import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _durationController = TextEditingController();
  int _selectedSportIndex = 0;
  bool _isSaving = false;

  static const List<String> _sportNames = ['Running', 'Cycling', 'Swimming', 'Weightlifting'];
  static const List<IconData> _sportIcons = [
    Icons.directions_run,
    Icons.directions_bike,
    Icons.pool,
    Icons.fitness_center,
  ];

  // Calories burned per minute — simplified MET-based averages
  static const List<int> _calPerMin = [10, 8, 11, 6];
  // Steps per minute estimate
  static const List<int> _stepsPerMin = [130, 80, 0, 0];

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _logActivity(String userId) async {
    final int? duration = int.tryParse(_durationController.text.trim());
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    final cal = _calPerMin[_selectedSportIndex] * duration;
    final steps = _stepsPerMin[_selectedSportIndex] * duration;

    try {
      await FirestoreService().addActivity(
        userId: userId,
        sportType: _sportNames[_selectedSportIndex],
        durationMinutes: duration,
        caloriesBurned: cal,
        stepsAdded: steps,
      );
      _durationController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged! +$steps steps · +$cal kcal'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteActivity(String userId, Map<String, dynamic> entry) async {
    try {
      await FirestoreService().deleteActivity(
        userId: userId,
        entryId: entry['id'],
        caloriesBurned: entry['caloriesBurned'] ?? 0,
        stepsAdded: entry['stepsAdded'] ?? 0,
        durationMinutes: entry['durationMinutes'] ?? 0,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid ?? '';
    final metricsProvider = Provider.of<MetricsProvider>(context);
    final today = metricsProvider.todayMetrics;

    const int dailyStepGoal = 10000;
    final int currentSteps = today?.steps ?? 0;
    final double progress = (currentSteps / dailyStepGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Activity Tracker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Circular Step Progress
            CircularPercentIndicator(
              radius: 110.0,
              lineWidth: 18.0,
              percent: progress,
              circularStrokeCap: CircularStrokeCap.round,
              backgroundColor: AppColors.surface,
              progressColor: AppColors.primary,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentSteps steps',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const Text(
                    'of 10,000',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Sport Selector + Log Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Sport', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_sportNames.length, (i) {
                      final isSelected = _selectedSportIndex == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedSportIndex = i),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary.withAlpha(30) : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                              ),
                              child: Icon(
                                _sportIcons[i],
                                size: 28,
                                color: isSelected ? AppColors.primary : AppColors.textHint,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _sportNames[i],
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? AppColors.primary : AppColors.textHint,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes)',
                      prefixIcon: const Icon(Icons.timer, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.background,
                      helperText: '≈ ${_calPerMin[_selectedSportIndex]} kcal/min · ${_stepsPerMin[_selectedSportIndex]} steps/min',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isSaving ? null : () => _logActivity(userId),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Log Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Today's Activities List
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().streamTodayActivities(userId),
              builder: (context, snapshot) {
                final activities = snapshot.data ?? [];
                if (activities.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                    child: const Center(
                      child: Text(
                        "No activities logged today.\nLog your first workout above!",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }
                return Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text("Today's Activities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      ),
                      ...activities.map((entry) {
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.fitness_center, color: Colors.white, size: 18),
                          ),
                          title: Text(entry['sportType'] ?? 'Exercise', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${entry['durationMinutes']} min · ${entry['caloriesBurned']} kcal · ${entry['stepsAdded']} steps'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _deleteActivity(userId, entry),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
