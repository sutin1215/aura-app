import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metric_card.dart';
import '../../routes/app_router.dart';

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

String _getAuraInsight(int steps, int waterMl, int sleepMinutes) {
  if (steps < 3000) {
    return "Start your day with a short walk — even 10 minutes makes a difference! 🚶";
  }
  if (waterMl < 500) {
    return "Don't forget to hydrate! Aim for at least 2L of water today. 💧";
  }
  if (sleepMinutes < 360 && DateTime.now().hour > 20) {
    return "Getting 7–8 hours of sleep is key to recovery. Try to rest soon! 😴";
  }
  if (steps > 8000) {
    return "Excellent work — you're almost at your step goal! Keep it up! 🔥";
  }
  return "Looking good! Keep logging your health data to stay on track with AURA! ✨";
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final metricsProvider = Provider.of<MetricsProvider>(context);
    final today = metricsProvider.todayMetrics;
    final username = auth.userProfile?.username ??
        auth.user?.email?.split('@')[0] ??
        'Explorer';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: false,
              title: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 56),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getGreeting(),
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        username,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(20),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textPrimary),
                    onPressed: () => context.push(AppRoutes.notifications),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── AURA Insight Card ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.gradientBox.copyWith(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(60),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(50),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.smart_toy,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AURA Insight',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getAuraInsight(
                                    today?.steps ?? 0,
                                    today?.waterIntakeMl ?? 0,
                                    today?.sleepMinutes ?? 0,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white.withAlpha(220),
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Today's Activity ───────────────────────────────────
                    Text("Today's Activity",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.85,
                      children: [
                        MetricCard(
                          title: 'Steps',
                          value: (today?.steps ?? 0).toString(),
                          unit: '/ 10k',
                          icon: Icons.directions_walk,
                          color: AppColors.steps,
                          progress: (today?.steps ?? 0) / 10000,
                          onTap: () => context.push(AppRoutes.activity),
                        ),
                        MetricCard(
                          title: 'Calories Burned',
                          value: (today?.caloriesBurned ?? 0).toString(),
                          unit: 'kcal',
                          icon: Icons.local_fire_department,
                          color: AppColors.calories,
                          progress: (today?.caloriesBurned ?? 0) / 600,
                          onTap: () => context.push(AppRoutes.activity),
                        ),
                        MetricCard(
                          title: 'Water',
                          value: (today?.waterIntakeMl ?? 0).toString(),
                          unit: 'ml',
                          icon: Icons.water_drop,
                          color: AppColors.water,
                          progress: (today?.waterIntakeMl ?? 0) / 2500,
                        ),
                        MetricCard(
                          title: 'Sleep',
                          value:
                              '${(today?.sleepMinutes ?? 0) ~/ 60}h ${(today?.sleepMinutes ?? 0) % 60}m',
                          unit: '',
                          icon: Icons.nights_stay,
                          color: AppColors.sleep,
                          progress: (today?.sleepMinutes ?? 0) / 480,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Quick Actions Grid ─────────────────────────────────
                    Text('Quick Actions',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.6,
                      children: [
                        _QuickAction(
                          label: 'Log Health',
                          icon: Icons.add_chart,
                          color: AppColors.primary,
                          onTap: () => context.push('/health-data'),
                        ),
                        _QuickAction(
                          label: 'Analytics',
                          icon: Icons.bar_chart,
                          color: AppColors.steps,
                          onTap: () => context.go(AppRoutes.analytics),
                        ),
                        _QuickAction(
                          label: 'My Goals',
                          icon: Icons.flag_outlined,
                          color: AppColors.success,
                          onTap: () => context.push(AppRoutes.goals),
                        ),
                        _QuickAction(
                          label: 'Healthcare',
                          icon: Icons.medical_services_outlined,
                          color: Colors.teal,
                          onTap: () =>
                              context.push(AppRoutes.healthcareInteraction),
                        ),
                        _QuickAction(
                          label: 'Hospital Locator',
                          icon: Icons.local_hospital_outlined,
                          color: Colors.deepPurple,
                          onTap: () => context.push(AppRoutes.hospitalLocator),
                        ),
                        _QuickAction(
                          label: 'Chat Provider',
                          icon: Icons.chat_bubble_outline,
                          color: AppColors.info,
                          onTap: () => context.push(AppRoutes.chatWithProvider),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Card ──────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
