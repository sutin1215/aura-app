import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/linear_progress_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userProfile = auth.userProfile;
    final metricsProvider = Provider.of<MetricsProvider>(context);
    final today = metricsProvider.todayMetrics;

    // Calculate BMI if profile bounds exist
    double bmi = 0;
    String bmiCategory = 'Unknown';
    if (userProfile != null && userProfile.height > 0) {
      // BMI = kg / (m^2)
      final heightInMeters = userProfile.height / 100;
      bmi = userProfile.weight / (heightInMeters * heightInMeters);

      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
      } else if (bmi >= 18.5 && bmi < 25) {
        bmiCategory = 'Normal';
      } else if (bmi >= 25 && bmi < 30) {
        bmiCategory = 'Overweight';
      } else {
        bmiCategory = 'Obese';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {}, // Future settings navigation
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: const Icon(Icons.person,
                        size: 50, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProfile?.username ?? 'AURA User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProfile?.email ?? 'Unknown Email',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // BMI Badge
                  if (bmi > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        'BMI: ${bmi.toStringAsFixed(1)} • $bmiCategory',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // My Goals Section (Moved from Activity)
            Text(
              'My Goals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 20),

            LinearProgressCard(
              title: 'Daily Steps',
              currentValue: '${today?.steps ?? 0}',
              targetValue: '10,000',
              icon: Icons.directions_walk,
              color: AppColors.steps,
              progress: (today?.steps ?? 0) / 10000,
            ),
            LinearProgressCard(
              title: 'Water Intake',
              currentValue: '${(today?.waterIntakeMl ?? 0) / 1000}L',
              targetValue: '2.5L',
              icon: Icons.water_drop,
              color: AppColors.water,
              progress: (today?.waterIntakeMl ?? 0) / 2500,
            ),
            LinearProgressCard(
              title: 'Calories Burned',
              currentValue: '${today?.caloriesBurned ?? 0}kcal',
              targetValue: '2,500kcal',
              icon: Icons.local_fire_department,
              color: AppColors.calories,
              progress: (today?.caloriesBurned ?? 0) / 2500,
            ),
            LinearProgressCard(
              title: 'Sleeping Hour',
              currentValue: '${(today?.sleepMinutes ?? 0) ~/ 60}h',
              targetValue: '8h',
              icon: Icons.nights_stay,
              color: AppColors.sleep,
              progress: (today?.sleepMinutes ?? 0) / 480,
            ),

            const SizedBox(height: 32),

            // Achievements Section
            Text(
              'Recent Achievements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAchievementBadge(
                      context, 'Early Bird', '🌅', AppColors.warning),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAchievementBadge(
                      context, '7 Day Streak', '🔥', AppColors.error),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Settings Menu
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),

            Container(
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
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline,
                        color: AppColors.primary),
                    title: const Text('Edit Profile',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.textHint),
                    onTap: () {
                      context.push(AppRoutes.editProfile);
                    },
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: const Icon(Icons.flag_outlined,
                        color: AppColors.primary),
                    title: const Text('My Goals',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.textHint),
                    onTap: () => context.push(AppRoutes.goals),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: const Icon(Icons.notifications_none,
                        color: AppColors.primary),
                    title: const Text('Notifications',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.textHint),
                    onTap: () => context.push(AppRoutes.notifications),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: const Icon(Icons.share, color: AppColors.primary),
                    title: const Text('Share Health Data',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.textHint),
                    onTap: () => context.push(AppRoutes.shareHealth),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: AppColors.primary),
                    title: const Text('Appointments',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.textHint),
                    onTap: () => context.push(AppRoutes.healthcareInteraction),
                  ),
                  _buildDivider(),
                  ListTile(
                    leading:
                        const Icon(Icons.settings, color: AppColors.primary),
                    title: const Text('Settings',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.textHint),
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  _buildDivider(),
                  // Logout Button
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text('Log Out',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error)),
                    onTap: () {
                      auth.signOut();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementBadge(
      BuildContext context, String title, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(50), width: 2),
        boxShadow: [
          BoxShadow(
              color: color.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: AppColors.textHint),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1,
        indent: 56,
        endIndent: 20,
        color: AppColors.textHint.withAlpha(50));
  }
}
