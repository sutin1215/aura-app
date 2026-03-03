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
  // 'week' or 'month'
  String _timeRange = 'week';
  
  // The current metric being viewed
  String _selectedMetric = 'steps';

  int get _daysCount => _timeRange == 'week' ? 7 : 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsListScreen()),
              );
            },
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
            label: const Text('Reports', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Consumer<MetricsProvider>(
        builder: (context, metricsProvider, child) {
          final historicalData = _filterData(metricsProvider.historicalMetrics);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTimeRangeToggle(),
                const SizedBox(height: 24),
                _buildMetricSelector(),
                const SizedBox(height: 32),
                
                if (historicalData.isEmpty)
                  _buildEmptyState()
                else
                  _buildChartCard(historicalData),
                  
                const SizedBox(height: 32),
                
                if (historicalData.isNotEmpty)
                  _buildSummaryStats(historicalData),
              ],
            ),
          );
        },
      ),
    );
  }

  // Filter data down to the selected time range
  List<HealthDay> _filterData(List<HealthDay> rawData) {
    if (rawData.isEmpty) return [];
    
    final cutoff = DateTime.now().subtract(Duration(days: _daysCount));
    
    // Sort chronological (oldest to newest) for the chart
    final filtered = rawData.where((d) => d.date.isAfter(cutoff)).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  Widget _buildTimeRangeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton('Week', 'week'),
          ),
          Expanded(
            child: _buildToggleButton('Month', 'month'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value) {
    final isSelected = _timeRange == value;
    return GestureDetector(
      onTap: () => setState(() => _timeRange = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _metricChip('Steps', 'steps', Icons.directions_walk, AppColors.steps),
          _metricChip('Calories', 'calories', Icons.local_fire_department, AppColors.calories),
          _metricChip('Heart Rate', 'heartRate', Icons.favorite, Colors.redAccent),
          _metricChip('Sleep', 'sleep', Icons.nights_stay, AppColors.sleep),
          _metricChip('Water', 'water', Icons.water_drop, AppColors.water),
          _metricChip('Weight', 'weight', Icons.monitor_weight, Colors.teal),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value, IconData icon, Color color) {
    final isSelected = _selectedMetric == value;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: ChoiceChip(
        label: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) setState(() => _selectedMetric = value);
        },
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.textHint.withAlpha(30),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart, size: 64, color: AppColors.textHint.withAlpha(100)),
          const SizedBox(height: 16),
          Text(
            'No data yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start logging your daily metrics to see your progress trends here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<HealthDay> data) {
    Color chartColor = AppColors.primary;
    if (_selectedMetric == 'steps') chartColor = AppColors.steps;
    if (_selectedMetric == 'calories') chartColor = AppColors.calories;
    if (_selectedMetric == 'heartRate') chartColor = Colors.redAccent;
    if (_selectedMetric == 'sleep') chartColor = AppColors.sleep;
    if (_selectedMetric == 'water') chartColor = AppColors.water;
    if (_selectedMetric == 'weight') chartColor = Colors.teal;

    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 20, left: 10, top: 24, bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getInterval(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textHint.withAlpha(20),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _timeRange == 'week' ? 1 : 7,
                getTitlesWidget: (value, meta) {
                  // value is the index in the data list
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    final date = data[index].date;
                    // For week view show day name (Mon), for month show date (15/10)
                    final format = _timeRange == 'week' ? DateFormat('E') : DateFormat('d/M');
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        format.format(date),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatAxisValue(value),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(data),
              isCurved: true,
              color: chartColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: _timeRange == 'week', // Only show dots on week view
              ),
              belowBarData: BarAreaData(
                show: true,
                color: chartColor.withAlpha(30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(List<HealthDay> data) {
    double total = 0;
    int countWithData = 0;
    
    for (var day in data) {
      final val = _getValueForMetric(day);
      if (val > 0) {
        total += val;
        countWithData++;
      }
    }
    
    final average = countWithData > 0 ? total / countWithData : 0.0;
    final unit = _getUnit();

    return Row(
      children: [
        Expanded(
          child: _statCard('Average', '${_formatValue(average)} $unit'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard('Total', '${_formatValue(total)} $unit'),
        ),
      ],
    );
  }
  
  Widget _statCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textHint.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(
            value, 
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: AppColors.textPrimary
            )
          ),
        ],
      ),
    );
  }

  // --- Helpers --- //

  double _getInterval() {
    switch (_selectedMetric) {
      case 'steps': return 2000;
      case 'calories': return 500;
      case 'heartRate': return 20;
      case 'sleep': return 120; // 2 hours in minutes
      case 'water': return 500;
      case 'weight': return 10;
      default: return 10;
    }
  }

  String _formatAxisValue(double value) {
    if (_selectedMetric == 'steps') return '${(value / 1000).toStringAsFixed(1)}k';
    if (_selectedMetric == 'sleep') return '${(value / 60).toStringAsFixed(0)}h';
    return value.toStringAsFixed(0);
  }

  String _formatValue(double value) {
    if (_selectedMetric == 'sleep') {
      final hours = value ~/ 60;
      final mins = (value % 60).toInt();
      return '${hours}h ${mins}m';
    }
    if (_selectedMetric == 'weight' || _selectedMetric == 'water') {
      // water is in ml, converting to L for display might be nice, but matching axis is better
      if (_selectedMetric == 'water') return (value / 1000).toStringAsFixed(1); 
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(0);
  }

  String _getUnit() {
    switch (_selectedMetric) {
      case 'steps': return 'steps';
      case 'calories': return 'kcal';
      case 'heartRate': return 'bpm';
      case 'sleep': return '';
      case 'water': return 'L';
      case 'weight': return 'kg';
      default: return '';
    }
  }

  List<FlSpot> _getSpots(List<HealthDay> data) {
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      final val = _getValueForMetric(data[i]);
      // For fl_chart, we need valid numbers. If 0 and we want to skip it, we can either plot 0 or exclude it. 
      // Excluding breaks the x-axis alignment unless x is a raw timestamp.
      spots.add(FlSpot(i.toDouble(), val.toDouble()));
    }
    return spots;
  }

  num _getValueForMetric(HealthDay day) {
    switch (_selectedMetric) {
      case 'steps': return day.steps;
      case 'calories': return day.caloriesBurned;
      case 'heartRate': return day.heartRate;
      case 'sleep': return day.sleepMinutes;
      case 'water': return day.waterIntakeMl;
      case 'weight': return day.weight;
      default: return 0;
    }
  }
}
