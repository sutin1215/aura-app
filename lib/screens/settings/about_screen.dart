import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _teamMembers = [
    {'name': 'Sutin', 'role': 'Lead Developer', 'emoji': '👨‍💻'},
    {'name': 'Faiza', 'role': 'UI/UX Designer', 'emoji': '🎨'},
    {'name': 'Member 3', 'role': 'Backend Developer', 'emoji': '⚙️'},
    {'name': 'Member 4', 'role': 'QA & Testing', 'emoji': '🧪'},
    {'name': 'Member 5', 'role': 'Project Manager', 'emoji': '📋'},
  ];

  static const _features = [
    {
      'icon': Icons.monitor_heart_outlined,
      'label': 'Health Metrics Tracking',
      'color': 0xFFFF6B6B
    },
    {
      'icon': Icons.smart_toy_outlined,
      'label': 'AI Health Companion',
      'color': 0xFF7B61FF
    },
    {
      'icon': Icons.people_outline,
      'label': 'Family Health Circle',
      'color': 0xFF4CAF50
    },
    {
      'icon': Icons.medical_services_outlined,
      'label': 'Provider Integration',
      'color': 0xFF6EC6F5
    },
    {
      'icon': Icons.bar_chart_outlined,
      'label': 'Advanced Analytics',
      'color': 0xFFFFC107
    },
    {
      'icon': Icons.calendar_month_outlined,
      'label': 'Appointment Management',
      'color': 0xFFFF9800
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About AURA'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'AURA',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your Virtual Health Companion',
                    style: TextStyle(
                        color: Colors.white.withAlpha(220), fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Version 1.0.0 · Demo Build',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── About Text ─────────────────────────────────────────────
            _sectionLabel('About'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'AURA is a comprehensive virtual health companion designed '
                'to help users track and improve their wellbeing. Built by '
                'Group 3 for the F29SO Software Engineering module at '
                'Heriot-Watt University.\n\n'
                'AURA integrates activity tracking, dietary logging, health '
                'analytics, AI-powered insights, and healthcare provider '
                'connectivity into one seamless experience.',
                style: TextStyle(
                    color: AppColors.textSecondary, height: 1.6, fontSize: 14),
              ),
            ),

            const SizedBox(height: 28),

            // ── Features ───────────────────────────────────────────────
            _sectionLabel('Key Features'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.4,
              children: _features.map((f) {
                final color = Color(f['color'] as int);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: color.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Icon(f['icon'] as IconData, color: color, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f['label'] as String,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── Team ───────────────────────────────────────────────────
            _sectionLabel('Meet the Team · Group 3'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: List.generate(_teamMembers.length, (i) {
                  final m = _teamMembers[i];
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(m['emoji']!,
                                style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        title: Text(m['name']!,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(m['role']!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                      ),
                      if (i < _teamMembers.length - 1)
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

            const SizedBox(height: 28),

            // ── Tech Stack ─────────────────────────────────────────────
            _sectionLabel('Built With'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Flutter',
                  'Firebase',
                  'GoRouter',
                  'Provider',
                  'Firestore',
                  'Dart 3.3+',
                  'fl_chart',
                  'Google Fonts',
                ]
                    .map((tech) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary.withAlpha(60)),
                          ),
                          child: Text(tech,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 28),

            // ── Footer ─────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Text(
                    '© 2025 AURA · Group 3 · F29SO',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Heriot-Watt University · Demo Only',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
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

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary),
      );
}
