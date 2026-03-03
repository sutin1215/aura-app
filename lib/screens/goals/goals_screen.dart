import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Available goal templates
  static const _goalTemplates = [
    {'name': 'Daily Steps',       'metric': 'steps',          'unit': 'steps',  'icon': Icons.directions_walk, 'defaultTarget': 10000.0},
    {'name': 'Water Intake',      'metric': 'waterIntakeMl',  'unit': 'ml',     'icon': Icons.water_drop,      'defaultTarget': 2000.0},
    {'name': 'Calories Burned',   'metric': 'caloriesBurned', 'unit': 'kcal',   'icon': Icons.local_fire_department, 'defaultTarget': 500.0},
    {'name': 'Sleep',             'metric': 'sleepMinutes',   'unit': 'min',    'icon': Icons.nights_stay,     'defaultTarget': 480.0},
  ];


  void _showAddGoalSheet() {
    String selectedMetric = 'steps';
    String selectedName = 'Daily Steps';
    final targetController = TextEditingController(text: '10000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add a Goal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 20),

                // Goal type chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _goalTemplates.map((t) {
                    final isSelected = selectedMetric == t['metric'];
                    return ChoiceChip(
                      avatar: Icon(t['icon'] as IconData, size: 16, color: isSelected ? Colors.white : AppColors.primary),
                      label: Text(t['name'] as String),
                      selected: isSelected,
                      onSelected: (_) {
                        setSheetState(() {
                          selectedMetric = t['metric'] as String;
                          selectedName = t['name'] as String;
                          targetController.text = (t['defaultTarget'] as double).toInt().toString();
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.background,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target (${_unitForMetric(selectedMetric)})',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      final target = double.tryParse(targetController.text);
                      if (target == null || target <= 0) return;
                      final userId = Provider.of<AuthProvider>(ctx, listen: false).user?.uid ?? '';
                      try {
                        await FirestoreService().addGoal(
                          userId: userId,
                          name: selectedName,
                          metric: selectedMetric,
                          target: target,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        // silently ignore for demo purposes
                      }
                    },
                    child: const Text('Save Goal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  String _unitForMetric(String metric) {
    switch (metric) {
      case 'steps': return 'steps';
      case 'waterIntakeMl': return 'ml';
      case 'caloriesBurned': return 'kcal';
      case 'sleepMinutes': return 'minutes';
      default: return '';
    }
  }

  double _currentValueForMetric(String metric, dynamic today) {
    if (today == null) return 0;
    switch (metric) {
      case 'steps': return (today.steps ?? 0).toDouble();
      case 'waterIntakeMl': return (today.waterIntakeMl ?? 0).toDouble();
      case 'caloriesBurned': return (today.caloriesBurned ?? 0).toDouble();
      case 'sleepMinutes': return (today.sleepMinutes ?? 0).toDouble();
      default: return 0;
    }
  }

  IconData _iconForMetric(String metric) {
    switch (metric) {
      case 'steps': return Icons.directions_walk;
      case 'waterIntakeMl': return Icons.water_drop;
      case 'caloriesBurned': return Icons.local_fire_department;
      case 'sleepMinutes': return Icons.nights_stay;
      default: return Icons.flag;
    }
  }

  Color _colorForMetric(String metric) {
    switch (metric) {
      case 'steps': return AppColors.steps;
      case 'waterIntakeMl': return AppColors.water;
      case 'caloriesBurned': return AppColors.calories;
      case 'sleepMinutes': return AppColors.sleep;
      default: return AppColors.primary;
    }
  }

  String _formatValue(String metric, double value) {
    if (metric == 'sleepMinutes') {
      final h = value ~/ 60;
      final m = (value % 60).toInt();
      return h > 0 ? '${h}h ${m}m' : '${m}m';
    }
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userId = auth.user?.uid ?? '';
    final today = Provider.of<MetricsProvider>(context).todayMetrics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goals & Achievements'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: _showAddGoalSheet,
            tooltip: 'Add Goal',
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().streamGoals(userId),
        builder: (context, snapshot) {
          final goals = snapshot.data ?? [];

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag_outlined, size: 80, color: AppColors.textHint.withAlpha(100)),
                  const SizedBox(height: 16),
                  const Text('No goals yet!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('Tap + to add your first goal', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Goal', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: _showAddGoalSheet,
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Summary header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6C63FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.white, size: 40),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today\'s Goals', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${goals.length} active goal${goals.length == 1 ? '' : 's'}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Goal cards
              ...goals.map((goal) {
                final metric = goal['metric'] as String? ?? 'steps';
                final target = (goal['target'] as num?)?.toDouble() ?? 0;
                final current = _currentValueForMetric(metric, today);
                final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
                final isComplete = progress >= 1.0;
                final color = _colorForMetric(metric);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: isComplete ? Border.all(color: AppColors.success, width: 2) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_iconForMetric(metric), color: color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(goal['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                                Text(
                                  '${_formatValue(metric, current)} / ${_formatValue(metric, target)} ${_unitForMetric(metric)}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          if (isComplete)
                            const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            onPressed: () => FirestoreService().deleteGoal(userId: userId, goalId: goal['id']),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: color.withAlpha(30),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isComplete ? AppColors.success : color,
                          ),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isComplete
                            ? '🎉 Goal achieved! Great work!'
                            : '${(progress * 100).toInt()}% complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: isComplete ? AppColors.success : AppColors.textHint,
                          fontWeight: isComplete ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
