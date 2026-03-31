import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../../data/partner_doctors.dart';
import '../../utils/demo_data_generator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // ── BMI helpers ──────────────────────────────────────────────────────────────
  double _calcBmi(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final h = heightCm / 100;
    return weightKg / (h * h);
  }

  _BmiInfo _bmiInfo(double bmi) {
    if (bmi <= 0) return const _BmiInfo('—', AppColors.textHint);
    if (bmi < 18.5) return const _BmiInfo('Underweight', AppColors.info);
    if (bmi < 25) return const _BmiInfo('Normal', AppColors.success);
    if (bmi < 30) return const _BmiInfo('Overweight', AppColors.warning);
    return const _BmiInfo('Obese', AppColors.error);
  }

  int _age(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profile = auth.userProfile;

    final bmi = _calcBmi(profile?.height ?? 0, profile?.weight ?? 0);
    final bmiInfo = _bmiInfo(bmi);
    final age = profile != null ? _age(profile.dateOfBirth) : 0;
    final isFemale = (profile?.gender ?? '').toLowerCase() == 'female';

    final providerId = profile?.assignedProviderId;
    final isConnected = providerId != null && providerId.isNotEmpty;
    final connectedDoctor = isConnected
        ? kPartnerDoctors.where((d) => d.hiddenUid == providerId).firstOrNull
        : null;

    // ── Static achievement badges for demo ───────────────────────────────────
    const badges = [
      {'emoji': '👟', 'label': 'Step Master', 'color': AppColors.steps},
      {'emoji': '🔥', 'label': '7-Day Streak', 'color': AppColors.calories},
      {'emoji': '💧', 'label': 'Hydration Hero', 'color': AppColors.water},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textPrimary),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── SECTION 1 — Hero Header ──────────────────────────────────────
            Center(
              child: Column(
                children: [
                  // Avatar with edit badge
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(60),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.primary.withAlpha(20),
                          backgroundImage: (profile?.avatarUrl ?? '').isNotEmpty
                              ? NetworkImage(profile!.avatarUrl!)
                              : null,
                          child: (profile?.avatarUrl ?? '').isEmpty
                              ? Text(
                                  (profile?.username ?? 'A')
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      // Edit pencil badge
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.editProfile),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.background, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary.withAlpha(80),
                                    blurRadius: 8),
                              ],
                            ),
                            child: const Icon(Icons.edit,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    profile?.username ?? 'AURA User',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile?.email ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  // Age · Gender row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _chip('$age yrs', Icons.cake_outlined, AppColors.primary),
                      const SizedBox(width: 8),
                      _chip(
                        profile?.gender ?? 'Not specified',
                        isFemale ? Icons.female : Icons.male,
                        isFemale ? Colors.pinkAccent : AppColors.info,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Health condition chips
                  if ((profile?.healthConditions ?? []).isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: (profile!.healthConditions)
                          .map((c) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withAlpha(15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.error.withAlpha(60)),
                                ),
                                child: Text(c,
                                    style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── SECTION 2 — Body Stats Bar ───────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.subtleShadow,
              ),
              child: Row(
                children: [
                  _statItem(
                    '${(profile?.height ?? 0).toStringAsFixed(0)} cm',
                    'Height',
                    Icons.height,
                    AppColors.primary,
                  ),
                  _vertDivider(),
                  _statItem(
                    '${(profile?.weight ?? 0).toStringAsFixed(1)} kg',
                    'Weight',
                    Icons.monitor_weight_outlined,
                    AppColors.steps,
                  ),
                  _vertDivider(),
                  _statItem(
                    bmi > 0 ? bmi.toStringAsFixed(1) : '—',
                    'BMI · ${bmiInfo.label}',
                    Icons.calculate_outlined,
                    bmiInfo.color,
                    onTap: () => _showBmiDialog(context, bmi, bmiInfo),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── SECTION 3 — Assigned Provider ────────────────────────────────
            _sectionLabel('Your Healthcare Provider'),
            const SizedBox(height: 12),
            if (isConnected)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withAlpha(50),
                        blurRadius: 14,
                        offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Text(connectedDoctor?.emoji ?? '👨‍⚕️',
                          style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(connectedDoctor?.name ?? 'Your Doctor',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(
                              '${connectedDoctor?.specialty ?? 'Healthcare Provider'} · Active',
                              style: TextStyle(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push(AppRoutes.chatWithProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, size: 15),
                      label: const Text('Message',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.subtleShadow,
                  border: Border.all(color: AppColors.primary.withAlpha(30)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_search_outlined,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('No Provider Linked',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          const Text(
                              'Connect with a doctor to unlock features.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.push(AppRoutes.healthcareInteraction),
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── SECTION 4 — Recent Achievements ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionLabel('Recent Achievements'),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.goals),
                  child: const Text(
                    'See all goals →',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: badges.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final b = badges[i];
                  final color = b['color'] as Color;
                  return Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withAlpha(60)),
                      boxShadow: AppTheme.subtleShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(b['emoji'] as String,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(
                          b['label'] as String,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── SECTION 5 — Quick Settings ────────────────────────────────────
            _sectionLabel('Quick Settings'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.subtleShadow,
              ),
              child: Column(
                children: [
                  // 🌟 MAGIC DEMO BUTTON STARTS HERE 🌟
                  _settingsTile(
                    context,
                    icon: Icons.auto_awesome,
                    color: Colors.orange,
                    title: 'Generate Demo Data',
                    subtitle: 'Pre-fill charts, meals, and activities',
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Generating golden path data... ✨')),
                      );
                      await DemoDataGenerator.populateGoldenPath(
                          auth.user!.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  '✅ Data populated! Navigate between tabs to refresh.'),
                              backgroundColor: AppColors.success),
                        );
                      }
                    },
                  ),
                  _divider(),
                  // 🌟 MAGIC DEMO BUTTON ENDS HERE 🌟
                  _settingsTile(
                    context,
                    icon: Icons.notifications_outlined,
                    color: AppColors.primary,
                    title: 'Notification Preferences',
                    subtitle: 'Manage your alert settings',
                    onTap: () => context.push('/settings/notifications'),
                  ),
                  _divider(),
                  _settingsTile(
                    context,
                    icon: Icons.share_outlined,
                    color: Colors.teal,
                    title: 'Share Health Data',
                    subtitle: 'Export & share with your provider',
                    onTap: () => context.push(AppRoutes.shareHealth),
                  ),
                  _divider(),
                  _settingsTile(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    color: AppColors.info,
                    title: 'Privacy & Data',
                    subtitle: 'Manage your data preferences',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon!')),
                    ),
                  ),
                  _divider(),
                  // Log Out — destructive, stands alone
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withAlpha(15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout,
                          color: AppColors.error, size: 20),
                    ),
                    title: const Text('Log Out',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.error)),
                    subtitle: const Text('Sign out of your AURA account',
                        style:
                            TextStyle(color: AppColors.textHint, fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.textHint),
                    onTap: () => _confirmLogout(context, auth),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary),
      );

  Widget _chip(String label, IconData icon, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _statItem(String value, String label, IconData icon, Color color, {VoidCallback? onTap}) {
    Widget content = Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: color)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
      ],
    );

    if (onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }

    return Expanded(child: content);
  }

  Widget _vertDivider() => Container(
        height: 48,
        width: 1,
        color: AppColors.textHint.withAlpha(40),
      );

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.textHint),
        onTap: onTap,
      );

  Widget _divider() => Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: AppColors.textHint.withAlpha(40));

  void _showBmiDialog(BuildContext context, double bmi, _BmiInfo info) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Your BMI',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bmi.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: 48, fontWeight: FontWeight.bold, color: info.color),
            ),
            const SizedBox(height: 4),
            Text(info.label,
                style: TextStyle(
                    color: info.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              'BMI (Body Mass Index) is a measure of body fat based on your height and weight. A normal BMI is between 18.5 and 24.9.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out of AURA?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                minimumSize: Size.zero,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
            onPressed: () {
              Navigator.pop(ctx);
              auth.signOut();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BmiInfo {
  final String label;
  final Color color;
  const _BmiInfo(this.label, this.color);
}
