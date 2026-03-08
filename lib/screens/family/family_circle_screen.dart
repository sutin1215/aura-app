import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

// ── Fake family members ────────────────────────────────────────────────────────
final _familyMembers = [
  {
    'name': 'Sarah (You)',
    'relation': 'Account Holder',
    'emoji': '👩',
    'color': AppColors.primary,
    'steps': 8420,
    'water': 1800,
    'sleep': 7,
    'status': 'active',
  },
  {
    'name': 'James',
    'relation': 'Husband',
    'emoji': '👨',
    'color': Colors.teal,
    'steps': 11250,
    'water': 2200,
    'sleep': 6,
    'status': 'active',
  },
  {
    'name': 'Emma',
    'relation': 'Daughter',
    'emoji': '👧',
    'color': Colors.pinkAccent,
    'steps': 6300,
    'water': 1500,
    'sleep': 9,
    'status': 'active',
  },
  {
    'name': 'Grandpa Tom',
    'relation': 'Father',
    'emoji': '👴',
    'color': Colors.deepPurple,
    'steps': 3100,
    'water': 1200,
    'sleep': 8,
    'status': 'inactive',
  },
  {
    'name': 'Grandma Rose',
    'relation': 'Mother',
    'emoji': '👵',
    'color': Colors.orange,
    'steps': 4500,
    'water': 1600,
    'sleep': 7,
    'status': 'inactive',
  },
];

class FamilyCircleScreen extends StatelessWidget {
  const FamilyCircleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active =
        _familyMembers.where((m) => m['status'] == 'active').toList();
    final inactive =
        _familyMembers.where((m) => m['status'] == 'inactive').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Family Circle'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.person_add_outlined, color: AppColors.primary),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invite feature coming soon!')),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Banner ────────────────────────────────────────────
            Container(
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
                      color: AppColors.primary.withAlpha(60),
                      blurRadius: 15,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Family Circle',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(
                        '${_familyMembers.length} members · ${active.length} active today',
                        style: TextStyle(
                            color: Colors.white.withAlpha(200), fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Active Members ─────────────────────────────────────────
            _sectionLabel('Active Today'),
            const SizedBox(height: 12),
            ...active.map((m) => _MemberCard(member: m, context: context)),

            const SizedBox(height: 24),

            // ── Inactive Members ───────────────────────────────────────
            _sectionLabel('Other Members'),
            const SizedBox(height: 12),
            ...inactive.map((m) => _MemberCard(member: m, context: context)),

            const SizedBox(height: 24),

            // ── Invite Card ────────────────────────────────────────────
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invite feature coming soon!')),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withAlpha(60),
                      style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_add_outlined,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Invite a Family Member',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        Text('Share your wellness journey together',
                            style: TextStyle(
                                color: AppColors.textHint, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: AppColors.textPrimary));
}

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final BuildContext context;

  const _MemberCard({required this.member, required this.context});

  @override
  Widget build(BuildContext ctx) {
    final color = member['color'] as Color;
    final isActive = member['status'] == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header row
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(member['emoji'] as String,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member['name'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary)),
                    Text(member['relation'] as String,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success.withAlpha(20)
                      : AppColors.textHint.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isActive ? 'Active' : 'Offline',
                  style: TextStyle(
                      color: isActive ? AppColors.success : AppColors.textHint,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          ),

          if (isActive) ...[
            const SizedBox(height: 14),
            // Mini stats row
            Row(
              children: [
                _miniStat('👟', '${member['steps']}', 'steps', color),
                _miniStat(
                    '💧', '${member['water']}ml', 'water', AppColors.water),
                _miniStat(
                    '😴', '${member['sleep']}h', 'sleep', AppColors.sleep),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniStat(String emoji, String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textPrimary)),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}
