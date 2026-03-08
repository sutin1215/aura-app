import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/metrics_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/health_metrics.dart';
import 'reports_list_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _timeRange = 'week';
  String _selectedMetric = 'steps';

  int get _daysCount => _timeRange == 'week' ? 7 : 30;

  // per-metric display config
  static const _metricConfig = {
    'steps': {
      'label': 'Steps',
      'icon': Icons.directions_walk,
      'color': AppColors.steps,
      'unit': 'steps',
      'goal': 10000.0
    },
    'calories': {
      'label': 'Calories',
      'icon': Icons.local_fire_department,
      'color': AppColors.calories,
      'unit': 'kcal',
      'goal': 2000.0
    },
    'heartRate': {
      'label': 'Heart Rate',
      'icon': Icons.favorite,
      'color': AppColors.heartRate,
      'unit': 'bpm',
      'goal': 70.0
    },
    'sleep': {
      'label': 'Sleep',
      'icon': Icons.nights_stay,
      'color': AppColors.sleep,
      'unit': 'min',
      'goal': 480.0
    },
    'water': {
      'label': 'Water',
      'icon': Icons.water_drop,
      'color': AppColors.water,
      'unit': 'ml',
      'goal': 2000.0
    },
    'weight': {
      'label': 'Weight',
      'icon': Icons.monitor_weight,
      'color': AppColors.weight,
      'unit': 'kg',
      'goal': 70.0
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsListScreen()),
            ),
            icon: const Icon(Icons.description_outlined,
                color: AppColors.primary),
            label: const Text('Reports',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Consumer<MetricsProvider>(
        builder: (context, mp, _) {
          final data = _filterData(mp.historicalMetrics);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Time toggle ─────────────────────────────────────
                _TimeToggle(
                  value: _timeRange,
                  onChanged: (v) => setState(() => _timeRange = v),
                ),
                const SizedBox(height: 20),

                // ── Metric chips ─────────────────────────────────────
                _MetricChips(
                  selected: _selectedMetric,
                  onSelect: (v) => setState(() => _selectedMetric = v),
                  config: _metricConfig,
                ),
                const SizedBox(height: 24),

                // ── Insight banner ────────────────────────────────────
                if (data.isNotEmpty)
                  _InsightBanner(
                    data: data,
                    metric: _selectedMetric,
                    config: _metricConfig[_selectedMetric]!,
                  ),

                const SizedBox(height: 16),

                // ── Chart ─────────────────────────────────────────────
                data.isEmpty
                    ? _emptyState()
                    : _ChartCard(
                        data: data,
                        metric: _selectedMetric,
                        timeRange: _timeRange,
                        config: _metricConfig[_selectedMetric]!,
                      ),

                const SizedBox(height: 20),

                // ── Summary Stats ─────────────────────────────────────
                if (data.isNotEmpty)
                  _SummaryStats(
                    data: data,
                    metric: _selectedMetric,
                    config: _metricConfig[_selectedMetric]!,
                  ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  List<HealthDay> _filterData(List<HealthDay> raw) {
    if (raw.isEmpty) return [];
    final cutoff = DateTime.now().subtract(Duration(days: _daysCount));
    final filtered = raw.where((d) => d.date.isAfter(cutoff)).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  Widget _emptyState() => Container(
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 64, color: AppColors.textHint.withAlpha(100)),
            const SizedBox(height: 16),
            const Text('No data yet',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Start logging your health metrics\nto see trends here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      );
}

// ── Time Toggle ───────────────────────────────────────────────────────────────
class _TimeToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _TimeToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: ['week', 'month'].map((opt) {
          final active = value == opt;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  opt == 'week' ? 'This Week' : 'This Month',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Metric Chips ──────────────────────────────────────────────────────────────
class _MetricChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final Map<String, dynamic> config;
  const _MetricChips(
      {required this.selected, required this.onSelect, required this.config});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: config.entries.map((e) {
          final key = e.key;
          final cfg = e.value as Map<String, dynamic>;
          final active = selected == key;
          final color = cfg['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onSelect(key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? color : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? color : AppColors.textHint.withAlpha(40)),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: color.withAlpha(60),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cfg['icon'] as IconData,
                        size: 16, color: active ? Colors.white : color),
                    const SizedBox(width: 6),
                    Text(
                      cfg['label'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: active ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Insight Banner ────────────────────────────────────────────────────────────
class _InsightBanner extends StatelessWidget {
  final List<HealthDay> data;
  final String metric;
  final Map<String, dynamic> config;
  const _InsightBanner(
      {required this.data, required this.metric, required this.config});

  num _val(HealthDay d) {
    switch (metric) {
      case 'steps':
        return d.steps;
      case 'calories':
        return d.caloriesBurned;
      case 'heartRate':
        return d.heartRate;
      case 'sleep':
        return d.sleepMinutes;
      case 'water':
        return d.waterIntakeMl;
      case 'weight':
        return d.weight;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final values = data.map(_val).where((v) => v > 0).toList();
    if (values.isEmpty) return const SizedBox.shrink();

    final avg = values.reduce((a, b) => a + b) / values.length;
    final goal = (config['goal'] as double?) ?? 1;
    final pct = ((avg / goal) * 100).clamp(0, 200);
    final color = config['color'] as Color;
    final unit = config['unit'] as String;

    String insight;
    if (pct >= 100) {
      insight = "You're hitting your ${config['label']} goal on average! 🎉";
    } else if (pct >= 70) {
      insight =
          "Almost there! Your ${config['label']} average is ${pct.toStringAsFixed(0)}% of goal.";
    } else {
      insight =
          "Room to grow — your ${config['label']} avg is ${_fmt(avg)} $unit. Keep pushing!";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(insight,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _fmt(num v) {
    if (metric == 'sleep') {
      return '${(v ~/ 60)}h ${(v % 60).toInt()}m';
    }
    if (v >= 1000 && metric == 'steps') {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return v is double ? v.toStringAsFixed(1) : v.toString();
  }
}

// ── Chart Card ────────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final List<HealthDay> data;
  final String metric;
  final String timeRange;
  final Map<String, dynamic> config;

  const _ChartCard({
    required this.data,
    required this.metric,
    required this.timeRange,
    required this.config,
  });

  num _val(HealthDay d) {
    switch (metric) {
      case 'steps':
        return d.steps;
      case 'calories':
        return d.caloriesBurned;
      case 'heartRate':
        return d.heartRate;
      case 'sleep':
        return d.sleepMinutes;
      case 'water':
        return d.waterIntakeMl;
      case 'weight':
        return d.weight;
      default:
        return 0;
    }
  }

  List<FlSpot> _spots() => List.generate(
      data.length, (i) => FlSpot(i.toDouble(), _val(data[i]).toDouble()));

  double _interval() {
    switch (metric) {
      case 'steps':
        return 2000;
      case 'calories':
        return 500;
      case 'heartRate':
        return 20;
      case 'sleep':
        return 120;
      case 'water':
        return 500;
      case 'weight':
        return 10;
      default:
        return 10;
    }
  }

  String _axisLabel(double v) {
    if (metric == 'steps') return '${(v / 1000).toStringAsFixed(0)}k';
    if (metric == 'sleep') return '${(v / 60).toStringAsFixed(0)}h';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final color = config['color'] as Color;
    final goal = (config['goal'] as double?) ?? 0;
    final showDots = timeRange == 'week';

    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _interval(),
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.textHint.withAlpha(20), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: timeRange == 'week' ? 1 : 7,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) return const Text('');
                  final date = data[index].date;
                  final label = timeRange == 'week'
                      ? DateFormat('E').format(date)
                      : DateFormat('d').format(date);
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (v, _) => Text(_axisLabel(v),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: goal > 0
              ? ExtraLinesData(horizontalLines: [
                  HorizontalLine(
                    y: goal,
                    color: color.withAlpha(80),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      labelResolver: (_) => 'Goal',
                    ),
                  ),
                ])
              : null,
          lineBarsData: [
            LineChartBarData(
              spots: _spots(),
              isCurved: true,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: showDots,
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [color.withAlpha(60), color.withAlpha(0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Stats ─────────────────────────────────────────────────────────────
class _SummaryStats extends StatelessWidget {
  final List<HealthDay> data;
  final String metric;
  final Map<String, dynamic> config;
  const _SummaryStats(
      {required this.data, required this.metric, required this.config});

  num _val(HealthDay d) {
    switch (metric) {
      case 'steps':
        return d.steps;
      case 'calories':
        return d.caloriesBurned;
      case 'heartRate':
        return d.heartRate;
      case 'sleep':
        return d.sleepMinutes;
      case 'water':
        return d.waterIntakeMl;
      case 'weight':
        return d.weight;
      default:
        return 0;
    }
  }

  String _fmt(double v) {
    if (metric == 'sleep') return '${(v ~/ 60)}h ${(v % 60).toInt()}m';
    if (metric == 'weight') return '${v.toStringAsFixed(1)} kg';
    if (metric == 'water') return '${(v / 1000).toStringAsFixed(1)} L';
    if (v >= 1000 && metric == 'steps') {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return '${v.toStringAsFixed(0)} ${config['unit']}';
  }

  @override
  Widget build(BuildContext context) {
    final values = data.map(_val).where((v) => v > 0).toList();
    if (values.isEmpty) return const SizedBox.shrink();

    final total = values.fold<num>(0, (a, b) => a + b);
    final avg = total / values.length;
    final peak = values.reduce((a, b) => a > b ? a : b);
    final low = values.reduce((a, b) => a < b ? a : b);
    final color = config['color'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Summary',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard('Average', _fmt(avg.toDouble()), color),
            const SizedBox(width: 12),
            _statCard('Peak', _fmt(peak.toDouble()), AppColors.success),
            const SizedBox(width: 12),
            _statCard('Lowest', _fmt(low.toDouble()), AppColors.textSecondary),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(40)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: color)),
            ],
          ),
        ),
      );
}
