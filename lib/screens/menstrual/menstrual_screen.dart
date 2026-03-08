import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_router.dart';

// ── Fake cycle data ────────────────────────────────────────────────────────────
final _cycleHistory = [
  {'start': DateTime(2025, 2, 3), 'end': DateTime(2025, 2, 7), 'length': 5},
  {'start': DateTime(2025, 1, 5), 'end': DateTime(2025, 1, 9), 'length': 5},
  {'start': DateTime(2024, 12, 8), 'end': DateTime(2024, 12, 12), 'length': 5},
];

final _nextPeriodDate = DateTime(2025, 3, 5);
final _lastPeriodDate = DateTime(2025, 2, 3);
const _avgCycleLength = 30;
const _avgPeriodLength = 5;

class MenstrualScreen extends StatelessWidget {
  const MenstrualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final daysUntil = _nextPeriodDate.difference(today).inDays;
    final daysUntilLabel = daysUntil > 0 ? 'In $daysUntil days' : 'Today';
    final cycleDay = today.difference(_lastPeriodDate).inDays + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Menstrual Cycle'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.editPeriod),
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.primary, size: 18),
            label: const Text('Log Period',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cycle Status Card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: Colors.pinkAccent.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day $cycleDay',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'of your cycle',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      const Text('🌸', style: TextStyle(fontSize: 52)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Cycle progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cycle Progress',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 13)),
                          Text('$cycleDay / $_avgCycleLength days',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (cycleDay / _avgCycleLength).clamp(0.0, 1.0),
                          backgroundColor: Colors.white.withAlpha(60),
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Prediction Cards ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    emoji: '📅',
                    title: 'Next Period',
                    value: daysUntilLabel,
                    sub: _fmtDate(_nextPeriodDate),
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _InfoCard(
                    emoji: '🔄',
                    title: 'Avg Cycle',
                    value: '$_avgCycleLength days',
                    sub: 'Avg period: $_avgPeriodLength days',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Phase Info ─────────────────────────────────────────────
            _sectionLabel(context, 'Current Phase'),
            const SizedBox(height: 12),
            _PhaseCard(cycleDay: cycleDay),

            const SizedBox(height: 24),

            // ── Symptoms Tracker ───────────────────────────────────────
            _sectionLabel(context, 'Log Today\'s Symptoms'),
            const SizedBox(height: 12),
            _SymptomsRow(context: context),

            const SizedBox(height: 24),

            // ── Cycle History ──────────────────────────────────────────
            _sectionLabel(context, 'Cycle History'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: List.generate(_cycleHistory.length, (i) {
                  final c = _cycleHistory[i];
                  final last = i == _cycleHistory.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent.withAlpha(20),
                            shape: BoxShape.circle,
                          ),
                          child:
                              const Text('🩸', style: TextStyle(fontSize: 18)),
                        ),
                        title: Text(
                          '${_fmtDate(c['start'] as DateTime)} – ${_fmtDate(c['end'] as DateTime)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: Text('${c['length']} days',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        trailing: const Icon(Icons.chevron_right,
                            color: AppColors.textHint),
                        onTap: () => context.push(AppRoutes.editPeriod),
                      ),
                      if (!last)
                        Divider(
                            height: 1,
                            indent: 56,
                            endIndent: 20,
                            color: AppColors.textHint.withAlpha(40)),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  Widget _sectionLabel(BuildContext context, String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary),
      );
}

// ── Phase Card ────────────────────────────────────────────────────────────────
class _PhaseCard extends StatelessWidget {
  final int cycleDay;
  const _PhaseCard({required this.cycleDay});

  @override
  Widget build(BuildContext context) {
    String phase, emoji, desc;
    Color color;

    if (cycleDay <= 5) {
      phase = 'Menstrual Phase';
      emoji = '🩸';
      desc = 'Your period is here. Rest well, stay warm, and stay hydrated.';
      color = Colors.pinkAccent;
    } else if (cycleDay <= 13) {
      phase = 'Follicular Phase';
      emoji = '🌱';
      desc = 'Energy rising! Great time for exercise and new challenges.';
      color = AppColors.success;
    } else if (cycleDay <= 16) {
      phase = 'Ovulation Phase';
      emoji = '⭐';
      desc = 'Peak energy and mood. Socialise and tackle big tasks today!';
      color = Colors.amber;
    } else {
      phase = 'Luteal Phase';
      emoji = '🌙';
      desc = 'Wind down and focus on self-care. Cravings are normal!';
      color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color)),
                const SizedBox(height: 4),
                Text(desc,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String emoji, title, value, sub;
  final Color color;
  const _InfoCard(
      {required this.emoji,
      required this.title,
      required this.value,
      required this.sub,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Symptoms Row ──────────────────────────────────────────────────────────────
class _SymptomsRow extends StatefulWidget {
  final BuildContext context;
  const _SymptomsRow({required this.context});
  @override
  State<_SymptomsRow> createState() => _SymptomsRowState();
}

class _SymptomsRowState extends State<_SymptomsRow> {
  final _symptoms = [
    {'emoji': '😣', 'label': 'Cramps', 'selected': false},
    {'emoji': '😮‍💨', 'label': 'Bloating', 'selected': false},
    {'emoji': '😔', 'label': 'Mood Dip', 'selected': false},
    {'emoji': '🤕', 'label': 'Headache', 'selected': false},
    {'emoji': '😴', 'label': 'Fatigue', 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _symptoms.map((s) {
        final sel = s['selected'] as bool;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => s['selected'] = !sel);
              if (!sel) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${s['label']} logged ✓'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.pinkAccent,
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color:
                    sel ? Colors.pinkAccent.withAlpha(30) : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: sel ? Colors.pinkAccent : AppColors.border),
              ),
              child: Column(
                children: [
                  Text(s['emoji'] as String,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    s['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.pinkAccent : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
