import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

// ── Fake monthly goals data (demo) ─────────────────────────────────────────────
const _monthlyGoals = [
  {
    'name': 'Monthly Steps',
    'metric': 'steps',
    'unit': 'steps',
    'target': 300000.0,
    'current': 187400.0
  },
  {
    'name': 'Monthly Water',
    'metric': 'waterIntakeMl',
    'unit': 'ml',
    'target': 75000.0,
    'current': 51200.0
  },
  {
    'name': 'Calories Burned',
    'metric': 'caloriesBurned',
    'unit': 'kcal',
    'target': 15000.0,
    'current': 9800.0
  },
  {
    'name': 'Sleep Hours',
    'metric': 'sleepMinutes',
    'unit': 'min',
    'target': 14400.0,
    'current': 10920.0
  },
];

// ── Achievement badge definitions ──────────────────────────────────────────────
const _achievements = [
  {
    'emoji': '👟',
    'title': 'Step Master',
    'desc': '10,000 steps in a day',
    'color': 0xFF7B61FF,
    'unlocked': true
  },
  {
    'emoji': '🔥',
    'title': '7-Day Streak',
    'desc': 'Logged 7 days in a row',
    'color': 0xFFFF6B6B,
    'unlocked': true
  },
  {
    'emoji': '💧',
    'title': 'Hydration Hero',
    'desc': 'Hit water goal 5 days',
    'color': 0xFF6EC6F5,
    'unlocked': true
  },
  {
    'emoji': '😴',
    'title': 'Sleep Champion',
    'desc': '8h sleep for 3 nights',
    'color': 0xFF9B87F5,
    'unlocked': false
  },
  {
    'emoji': '🥗',
    'title': 'Diet Devotee',
    'desc': 'Logged meals for 7 days',
    'color': 0xFF4CAF50,
    'unlocked': false
  },
  {
    'emoji': '🏆',
    'title': 'All-Star',
    'desc': 'Complete all daily goals',
    'color': 0xFFFFC107,
    'unlocked': false
  },
];

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showMonthly = false;

  static const _goalTemplates = [
    {
      'name': 'Daily Steps',
      'metric': 'steps',
      'unit': 'steps',
      'icon': Icons.directions_walk,
      'defaultTarget': 10000.0
    },
    {
      'name': 'Water Intake',
      'metric': 'waterIntakeMl',
      'unit': 'ml',
      'icon': Icons.water_drop,
      'defaultTarget': 2000.0
    },
    {
      'name': 'Calories Burned',
      'metric': 'caloriesBurned',
      'unit': 'kcal',
      'icon': Icons.local_fire_department,
      'defaultTarget': 500.0
    },
    {
      'name': 'Sleep',
      'metric': 'sleepMinutes',
      'unit': 'min',
      'icon': Icons.nights_stay,
      'defaultTarget': 480.0
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _unitForMetric(String metric) {
    switch (metric) {
      case 'steps':
        return 'steps';
      case 'waterIntakeMl':
        return 'ml';
      case 'caloriesBurned':
        return 'kcal';
      case 'sleepMinutes':
        return 'min';
      default:
        return '';
    }
  }

  double _currentValueForMetric(String metric, dynamic today) {
    if (today == null) return 0;
    switch (metric) {
      case 'steps':
        return (today.steps ?? 0).toDouble();
      case 'waterIntakeMl':
        return (today.waterIntakeMl ?? 0).toDouble();
      case 'caloriesBurned':
        return (today.caloriesBurned ?? 0).toDouble();
      case 'sleepMinutes':
        return (today.sleepMinutes ?? 0).toDouble();
      default:
        return 0;
    }
  }

  IconData _iconForMetric(String metric) {
    switch (metric) {
      case 'steps':
        return Icons.directions_walk;
      case 'waterIntakeMl':
        return Icons.water_drop;
      case 'caloriesBurned':
        return Icons.local_fire_department;
      case 'sleepMinutes':
        return Icons.nights_stay;
      default:
        return Icons.flag;
    }
  }

  Color _colorForMetric(String metric) {
    switch (metric) {
      case 'steps':
        return AppColors.steps;
      case 'waterIntakeMl':
        return AppColors.water;
      case 'caloriesBurned':
        return AppColors.calories;
      case 'sleepMinutes':
        return AppColors.sleep;
      default:
        return AppColors.primary;
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

  // ── Add Goal Sheet ────────────────────────────────────────────────────────────

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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Add a Goal',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textHint),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _goalTemplates.map((t) {
                  final isSelected = selectedMetric == t['metric'];
                  return ChoiceChip(
                    avatar: Icon(t['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primary),
                    label: Text(t['name'] as String),
                    selected: isSelected,
                    onSelected: (_) => setSheet(() {
                      selectedMetric = t['metric'] as String;
                      selectedName = t['name'] as String;
                      targetController.text =
                          (t['defaultTarget'] as double).toInt().toString();
                    }),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target (${_unitForMetric(selectedMetric)})',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: AppColors.background,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final target = double.tryParse(targetController.text);
                    if (target == null || target <= 0) return;
                    final userId = Provider.of<AuthProvider>(ctx, listen: false)
                            .user
                            ?.uid ??
                        '';
                    try {
                      await FirestoreService().addGoal(
                        userId: userId,
                        name: selectedName,
                        metric: selectedMetric,
                        target: target,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (_) {}
                  },
                  child: const Text('Save Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Goals'),
            Tab(text: 'Achievements'),
          ],
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.primary),
              onPressed: _showAddGoalSheet,
              tooltip: 'Add Goal',
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _GoalsTab(
            userId: userId,
            today: today,
            showMonthly: _showMonthly,
            onToggle: (v) => setState(() => _showMonthly = v),
            currentFor: _currentValueForMetric,
            iconFor: _iconForMetric,
            colorFor: _colorForMetric,
            formatValue: _formatValue,
            unitFor: _unitForMetric,
            onAddGoal: _showAddGoalSheet,
          ),
          const _AchievementsTab(),
        ],
      ),
    );
  }
}

// ── Goals Tab ─────────────────────────────────────────────────────────────────

class _GoalsTab extends StatelessWidget {
  final String userId;
  final dynamic today;
  final bool showMonthly;
  final ValueChanged<bool> onToggle;
  final double Function(String, dynamic) currentFor;
  final IconData Function(String) iconFor;
  final Color Function(String) colorFor;
  final String Function(String, double) formatValue;
  final String Function(String) unitFor;
  final VoidCallback onAddGoal;

  const _GoalsTab({
    required this.userId,
    required this.today,
    required this.showMonthly,
    required this.onToggle,
    required this.currentFor,
    required this.iconFor,
    required this.colorFor,
    required this.formatValue,
    required this.unitFor,
    required this.onAddGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Daily / Monthly Toggle ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                _toggleBtn(
                    context, 'Daily', !showMonthly, () => onToggle(false)),
                _toggleBtn(
                    context, 'Monthly', showMonthly, () => onToggle(true)),
              ],
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────────────────
        Expanded(
          child: showMonthly
              ? _buildMonthlyGoals(context)
              : _buildDailyGoals(context),
        ),
      ],
    );
  }

  Widget _toggleBtn(
      BuildContext context, String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Daily (live Firestore) ────────────────────────────────────────────────

  Widget _buildDailyGoals(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService().streamGoals(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final goals = snapshot.data ?? [];
        if (goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag_outlined,
                    size: 72, color: AppColors.textHint.withAlpha(100)),
                const SizedBox(height: 16),
                const Text('No goals yet!',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                const Text('Tap + to add your first goal',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Add Goal'),
                  onPressed: onAddGoal,
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _summaryBanner(
                context,
                '${goals.length} Daily Goal${goals.length == 1 ? '' : 's'}',
                'Keep pushing — every step counts!'),
            const SizedBox(height: 20),
            ...goals.map((goal) => _goalCard(context, goal)),
          ],
        );
      },
    );
  }

  // ── Monthly (fake static data) ────────────────────────────────────────────

  Widget _buildMonthlyGoals(BuildContext context) {
    final month = _monthName(DateTime.now().month);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _summaryBanner(
            context, '$month Goals', 'Your monthly progress summary'),
        const SizedBox(height: 20),
        ..._monthlyGoals.map((g) {
          final metric = g['metric'] as String;
          final target = g['target'] as double;
          final current = g['current'] as double;
          final progress = (current / target).clamp(0.0, 1.0);
          final color = colorFor(metric);
          final isDone = progress >= 1.0;
          return _goalCardStatic(
            context,
            name: g['name'] as String,
            metric: metric,
            current: current,
            target: target,
            progress: progress,
            color: color,
            isDone: isDone,
          );
        }),
      ],
    );
  }

  Widget _summaryBanner(BuildContext context, String title, String sub) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(60),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(sub,
                  style: TextStyle(
                      color: Colors.white.withAlpha(200), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _goalCard(BuildContext context, Map<String, dynamic> goal) {
    final metric = goal['metric'] as String? ?? 'steps';
    final target = (goal['target'] as num?)?.toDouble() ?? 0;
    final current = currentFor(metric, today);
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final isDone = progress >= 1.0;
    final color = colorFor(metric);

    return _goalCardStatic(
      context,
      name: goal['name'] ?? '',
      metric: metric,
      current: current,
      target: target,
      progress: progress,
      color: color,
      isDone: isDone,
      goalId: goal['id'],
    );
  }

  Widget _goalCardStatic(
    BuildContext context, {
    required String name,
    required String metric,
    required double current,
    required double target,
    required double progress,
    required Color color,
    required bool isDone,
    String? goalId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDone ? Border.all(color: AppColors.success, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
        ],
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
                child: Icon(iconFor(metric), color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary)),
                    Text(
                      '${formatValue(metric, current)} / ${formatValue(metric, target)} ${unitFor(metric)}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (isDone)
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 22),
              if (goalId != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  onPressed: () => FirestoreService()
                      .deleteGoal(userId: userId, goalId: goalId),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(
                  isDone ? AppColors.success : color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isDone
                ? '🎉 Goal achieved! Great work!'
                : '${(progress * 100).toInt()}% complete',
            style: TextStyle(
              fontSize: 12,
              color: isDone ? AppColors.success : AppColors.textHint,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[month];
  }
}

// ── Achievements Tab ──────────────────────────────────────────────────────────

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab();

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a['unlocked'] == true).toList();
    final locked = _achievements.where((a) => a['unlocked'] == false).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Banner ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.orange.withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Achievements',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text(
                    '${unlocked.length} of ${_achievements.length} unlocked',
                    style: TextStyle(
                        color: Colors.white.withAlpha(220), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ── Unlocked ────────────────────────────────────────────────────
        const Text('Unlocked',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: unlocked
              .map((a) => _BadgeCard(achievement: a, locked: false))
              .toList(),
        ),

        const SizedBox(height: 28),

        // ── Locked ──────────────────────────────────────────────────────
        const Text('Locked',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: locked
              .map((a) => _BadgeCard(achievement: a, locked: true))
              .toList(),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final Map<String, Object> achievement;
  final bool locked;

  const _BadgeCard({required this.achievement, required this.locked});

  @override
  Widget build(BuildContext context) {
    final color = Color(achievement['color'] as int);

    return Container(
      decoration: BoxDecoration(
        color: locked ? AppColors.surface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              locked ? AppColors.textHint.withAlpha(40) : color.withAlpha(80),
          width: 2,
        ),
        boxShadow: locked
            ? []
            : [
                BoxShadow(
                  color: color.withAlpha(30),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          locked
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(achievement['emoji'] as String,
                        style: TextStyle(
                            fontSize: 36, color: Colors.black.withAlpha(20))),
                    const Icon(Icons.lock, color: AppColors.textHint, size: 28),
                  ],
                )
              : Text(achievement['emoji'] as String,
                  style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            achievement['title'] as String,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: locked ? AppColors.textHint : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            achievement['desc'] as String,
            style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
