import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/metric_card.dart';
import '../health/health_data_screen.dart';
import '../../routes/app_router.dart';

String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

String _getAuraInsight(int steps, int waterMl, int sleepMinutes) {
  final hour = DateTime.now().hour;
  if (steps < 3000) return "Start your day with a short walk — even 10 minutes makes a difference! 🚶";
  if (waterMl < 500) return "Don't forget to hydrate! Aim for at least 2L of water today. 💧";
  if (sleepMinutes < 360 && hour > 20) return "Getting 7–8 hours of sleep is key to recovery. Try to rest soon! 😴";
  if (steps > 8000) return "Excellent work — you're almost at your step goal! Keep it up! 🔥";
  return "Looking good! Keep logging your health data to stay on track with AURA!";
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    
    // Listen to live metrics
    final metricsProvider = Provider.of<MetricsProvider>(context);
    final today = metricsProvider.todayMetrics;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: false,
              title: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 65),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        auth.userProfile?.username ?? user?.email?.split('@')[0] ?? 'Explorer',
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
                      )
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
                    onPressed: () => context.push(AppRoutes.notifications),
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AURA Companion Tip
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
                            child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AURA Insight',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

                    // Metrics Header
                    Text(
                      'Today\'s Activity',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Metrics Grid
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
                          value: today?.steps.toString() ?? '0',
                          unit: '/ 10k',
                          icon: Icons.directions_walk,
                          color: AppColors.steps,
                          progress: (today?.steps ?? 0) / 10000,
                        ),
                        MetricCard(
                          title: 'Calories',
                          value: today?.caloriesBurned.toString() ?? '0',
                          unit: 'kcal',
                          icon: Icons.local_fire_department,
                          color: AppColors.calories,
                          progress: (today?.caloriesBurned ?? 0) / 2500, // example goal
                        ),
                        MetricCard(
                          title: 'Water',
                          value: today?.waterIntakeMl.toString() ?? '0',
                          unit: 'ml',
                          icon: Icons.water_drop,
                          color: AppColors.water,
                          progress: (today?.waterIntakeMl ?? 0) / 2000,
                        ),
                        MetricCard(
                          title: 'Sleep',
                          value: '${(today?.sleepMinutes ?? 0) ~/ 60}h ${(today?.sleepMinutes ?? 0) % 60}m',
                          icon: Icons.nights_stay,
                          color: AppColors.sleep,
                          progress: (today?.sleepMinutes ?? 0) / 480, // 8 hours
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_chart, color: Colors.white),
                            label: const Text('Log Health', style: TextStyle(color: Colors.white, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HealthDataScreen()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.bar_chart, color: AppColors.primary),
                            label: const Text('Analytics', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              context.go(AppRoutes.analytics);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Goals shortcut
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.flag_outlined, color: AppColors.primary),
                        label: const Text('View Goals', style: TextStyle(color: AppColors.primary, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        onPressed: () => context.push(AppRoutes.goals),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Hospital Locator shortcut
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.local_hospital_outlined, color: Colors.deepPurple),
                        label: const Text('Locate Hospital Near Me', style: TextStyle(color: Colors.deepPurple, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: Colors.deepPurple),
                        ),
                        onPressed: () => context.push(AppRoutes.hospitalLocator),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Chat with Provider shortcut
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                        label: const Text('Chat with Provider', style: TextStyle(color: Colors.teal, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: Colors.teal),
                        ),
                        onPressed: () => context.push(AppRoutes.chatWithProvider),
                      ),
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
