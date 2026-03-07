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

    // BMI calculation
    double bmi = 0;
    String bmiCategory = '';
    Color bmiColor = AppColors.success;
    if (userProfile != null && userProfile.height > 0) {
      final hm = userProfile.height / 100;
      bmi = userProfile.weight / (hm * hm);
      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
        bmiColor = AppColors.info;
      } else if (bmi < 25) {
        bmiCategory = 'Normal';
        bmiColor = AppColors.success;
      } else if (bmi < 30) {
        bmiCategory = 'Overweight';
        bmiColor = AppColors.warning;
      } else {
        bmiCategory = 'Obese';
        bmiColor = AppColors.error;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textPrimary),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar + Name ────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: AppColors.primary.withAlpha(30),
                      child: const Icon(Icons.person,
                          size: 52, color: AppColors.primary),
                    ),
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
                    userProfile?.email ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // Stats row
                  if (userProfile != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withAlpha(5), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _statChip(
                              'Height',
                              '${userProfile.height.toInt()} cm',
                              AppColors.primary),
                          _vDivider(),
                          _statChip(
                              'Weight',
                              '${userProfile.weight.toStringAsFixed(1)} kg',
                              AppColors.steps),
                          if (bmi > 0) ...[
                            _vDivider(),
                            _statChip('BMI', bmi.toStringAsFixed(1), bmiColor),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (bmi > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: bmiColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bmiCategory,
                          style: TextStyle(
                            color: bmiColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Today's Progress ─────────────────────────────────────────
            Text("Today's Progress",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),

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
              currentValue:
                  '${((today?.waterIntakeMl ?? 0) / 1000).toStringAsFixed(1)}L',
              targetValue: '2.5L',
              icon: Icons.water_drop,
              color: AppColors.water,
              progress: (today?.waterIntakeMl ?? 0) / 2500,
            ),
            LinearProgressCard(
              title: 'Calories Consumed',
              currentValue: '${today?.caloriesConsumed ?? 0} kcal',
              targetValue: '2,000 kcal',
              icon: Icons.restaurant,
              color: AppColors.calories,
              progress: (today?.caloriesConsumed ?? 0) / 2000,
            ),
            LinearProgressCard(
              title: 'Sleep',
              currentValue:
                  '${(today?.sleepMinutes ?? 0) ~/ 60}h ${(today?.sleepMinutes ?? 0) % 60}m',
              targetValue: '8h',
              icon: Icons.nights_stay,
              color: AppColors.sleep,
              progress: (today?.sleepMinutes ?? 0) / 480,
            ),

            const SizedBox(height: 32),

            // ── Achievements ─────────────────────────────────────────────
            Text('Recent Achievements',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child:
                        _badge(context, 'Early Bird', '🌅', AppColors.warning)),
                const SizedBox(width: 16),
                Expanded(
                    child:
                        _badge(context, '7 Day Streak', '🔥', AppColors.error)),
              ],
            ),

            const SizedBox(height: 36),

            // ── Menu ─────────────────────────────────────────────────────
            Text('My Account',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 16),

            _menuCard(children: [
              _menuItem(context, 'Edit Profile', Icons.person_outline,
                  AppColors.primary, () => context.push(AppRoutes.editProfile)),
              _divider(),
              _menuItem(context, 'My Goals', Icons.flag_outlined,
                  AppColors.success, () => context.push(AppRoutes.goals)),
              _divider(),
              _menuItem(
                  context,
                  'Healthcare',
                  Icons.medical_services_outlined,
                  Colors.teal,
                  () => context.push(AppRoutes.healthcareInteraction)),
              _divider(),
              _menuItem(
                  context,
                  'Family Circle',
                  Icons.people_outline,
                  Colors.deepPurple,
                  () => context.push(AppRoutes.familyCircle)),
              _divider(),
              _menuItem(
                  context,
                  'Menstrual Cycle',
                  Icons.calendar_month_outlined,
                  Colors.pinkAccent,
                  () => context.push(AppRoutes.menstrualCycle)),
              _divider(),
              _menuItem(context, 'Share Health Data', Icons.share_outlined,
                  AppColors.info, () => context.push(AppRoutes.shareHealth)),
              _divider(),
              _menuItem(
                  context,
                  'Notifications',
                  Icons.notifications_none,
                  AppColors.primary,
                  () => context.push(AppRoutes.notifications)),
              _divider(),
              _menuItem(
                  context,
                  'Settings',
                  Icons.settings_outlined,
                  AppColors.textSecondary,
                  () => context.push(AppRoutes.settings)),
            ]),

            const SizedBox(height: 16),

            // ── Logout ────────────────────────────────────────────────────
            _menuCard(children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout,
                      color: AppColors.error, size: 20),
                ),
                title: const Text('Log Out',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.error)),
                onTap: () => auth.signOut(),
              ),
            ]),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _statChip(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 36,
        color: AppColors.textHint.withAlpha(40),
      );

  Widget _badge(BuildContext context, String title, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60), width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _menuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }

  Widget _divider() => Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: AppColors.textHint.withAlpha(40));
}
