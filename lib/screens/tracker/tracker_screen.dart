import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_router.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile =
        Provider.of<AuthProvider>(context, listen: false).userProfile;
    final isFemale = (profile?.gender ?? '').toLowerCase() == 'female';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Health Tracker'),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TodaySummary(),

              const SizedBox(height: 28),

              const Text(
                'What would you like to update?',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              const _TrackerCard(
                title: 'Activity Tracker',
                subtitle: 'Log exercises, workouts & active minutes.',
                icon: Icons.directions_run_rounded,
                color: AppColors.primary,
                route: AppRoutes.activity,
              ),
              const SizedBox(height: 14),

              const _TrackerCard(
                title: 'Diet Log',
                subtitle: 'Track meals, calories & nutritional intake.',
                icon: Icons.restaurant_rounded,
                color: AppColors.calories,
                route: AppRoutes.diet,
              ),
              const SizedBox(height: 14),

              const _TrackerCard(
                title: 'Health Vitals',
                subtitle: 'Log heart rate, weight, blood pressure & more.',
                icon: Icons.monitor_heart_outlined,
                color: AppColors.heartRate,
                route: '/health-data',
                badge: 'Vitals',
              ),

              // Female-only: Menstrual Cycle card
              if (isFemale) ...[
                const SizedBox(height: 14),
                const _TrackerCard(
                  title: 'Menstrual Cycle',
                  subtitle: 'Track your cycle, symptoms & period predictions.',
                  icon: Icons.favorite_outline,
                  color: Colors.pinkAccent,
                  route: '/menstrual-cycle',
                  badge: 'Cycle',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Today's Live Summary ──────────────────────────────────────────────────────
class _TodaySummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MetricsProvider>(
      builder: (context, mp, _) {
        final m = mp.todayMetrics;
        final steps = m?.steps ?? 0;
        final water = m?.waterIntakeMl ?? 0;
        final cal = m?.caloriesBurned ?? 0;
        final sleep = m?.sleepMinutes ?? 0;

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
                  color: AppColors.primary.withAlpha(50),
                  blurRadius: 16,
                  offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("📊", style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  const Text(
                    "Today's Progress",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _todayLabel(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _statPill('👟', '$steps', 'steps'),
                  _statPill(
                      '💧', '${(water / 1000).toStringAsFixed(1)}L', 'water'),
                  _statPill('🔥', '$cal', 'kcal'),
                  _statPill(
                      '😴', '${(sleep / 60).toStringAsFixed(1)}h', 'sleep'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statPill(String emoji, String value, String label) => Expanded(
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withAlpha(180), fontSize: 10)),
          ],
        ),
      );

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
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
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

// ── Tracker Card ──────────────────────────────────────────────────────────────
class _TrackerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final String? badge;

  const _TrackerCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(20),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: color.withAlpha(20), shape: BoxShape.circle),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                              color: color.withAlpha(20),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(badge!,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.arrow_forward_ios, color: color, size: 13),
            ),
          ],
        ),
      ),
    );
  }
}
