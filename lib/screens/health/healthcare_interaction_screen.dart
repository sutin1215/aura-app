import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';

// ── Fake appointment data (demo) ───────────────────────────────────────────────
final _fakeAppointments = [
  {
    'doctorName': 'Dr. Kang',
    'specialty': 'General Practice',
    'dateTime': DateTime.now().add(const Duration(days: 3, hours: 2)),
    'note': 'Follow-up on blood pressure readings',
    'status': 'upcoming',
    'avatar': '👨‍⚕️',
  },
  {
    'doctorName': 'Dr. Kang',
    'specialty': 'General Practice',
    'dateTime': DateTime.now().subtract(const Duration(days: 14)),
    'note': 'Routine check-up completed',
    'status': 'past',
    'avatar': '👨‍⚕️',
  },
  {
    'doctorName': 'Dr. Kang',
    'specialty': 'General Practice',
    'dateTime': DateTime.now().subtract(const Duration(days: 45)),
    'note': 'Initial consultation',
    'status': 'past',
    'avatar': '👨‍⚕️',
  },
];

class HealthcareInteractionScreen extends StatelessWidget {
  const HealthcareInteractionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final upcoming =
        _fakeAppointments.where((a) => a['status'] == 'upcoming').toList();
    final past = _fakeAppointments.where((a) => a['status'] == 'past').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Healthcare'),
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
            // ── Assigned Provider Card ───────────────────────────────────
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
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('👨‍⚕️', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dr. Kang',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'General Practice · Assigned Provider',
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✅ Active',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ───────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.chat_bubble_outline,
                    label: 'Message\nProvider',
                    color: AppColors.primary,
                    onTap: () => context.push(AppRoutes.chatWithProvider),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.calendar_month_outlined,
                    label: 'Make\nAppointment',
                    color: Colors.teal,
                    onTap: () => context.push(AppRoutes.makeAppointment),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.share_outlined,
                    label: 'Share\nHealth Data',
                    color: Colors.deepPurple,
                    onTap: () => context.push(AppRoutes.shareHealth),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Upcoming Appointments ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Upcoming Appointments',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push(AppRoutes.makeAppointment),
                  child: const Text('+ Book'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (upcoming.isEmpty)
              _emptyCard(
                context,
                icon: Icons.event_available_outlined,
                message: 'No upcoming appointments',
                sub: 'Tap "+ Book" to schedule one',
              )
            else
              ...upcoming.map((a) => _AppointmentCard(appt: a, isPast: false)),

            const SizedBox(height: 28),

            // ── Past Appointments ────────────────────────────────────────
            Text('Past Appointments',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (past.isEmpty)
              _emptyCard(context,
                  icon: Icons.history, message: 'No past appointments')
            else
              ...past.map((a) => _AppointmentCard(appt: a, isPast: true)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(BuildContext context,
      {required IconData icon, required String message, String? sub}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.textHint.withAlpha(120)),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub,
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

// ── Action Card ───────────────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Appointment Card ──────────────────────────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appt;
  final bool isPast;

  const _AppointmentCard({required this.appt, required this.isPast});

  @override
  Widget build(BuildContext context) {
    final dt = appt['dateTime'] as DateTime;
    final color = isPast ? AppColors.textHint : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            isPast ? null : Border.all(color: AppColors.primary.withAlpha(80)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(appt['avatar'] as String,
                  style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt['doctorName'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isPast
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(dt),
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                if ((appt['note'] as String).isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    appt['note'] as String,
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isPast ? 'Past' : 'Upcoming',
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
