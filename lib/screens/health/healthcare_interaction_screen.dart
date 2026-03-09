import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../../data/partner_doctors.dart';

final _fakeAppointments = [
  {
    'doctorName': 'Dr. Sarah Kang',
    'specialty': 'General Practice',
    'dateTime': DateTime.now().add(const Duration(days: 3, hours: 2)),
    'note': 'Follow-up on blood pressure readings',
    'status': 'upcoming',
  },
  {
    'doctorName': 'Dr. Sarah Kang',
    'specialty': 'General Practice',
    'dateTime': DateTime.now().subtract(const Duration(days: 14)),
    'note': 'Routine check-up completed',
    'status': 'past',
  },
  {
    'doctorName': 'Dr. Sarah Kang',
    'specialty': 'General Practice',
    'dateTime': DateTime.now().subtract(const Duration(days: 45)),
    'note': 'Initial consultation',
    'status': 'past',
  },
];

class HealthcareInteractionScreen extends StatelessWidget {
  const HealthcareInteractionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final providerId = auth.userProfile?.assignedProviderId;
    final isConnected = providerId != null && providerId.isNotEmpty;

    final connectedDoctor = isConnected
        ? kPartnerDoctors.where((d) => d.hiddenUid == providerId).firstOrNull
        : null;

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
            if (isConnected) ...[
              _ConnectedDoctorCard(
                doctor: connectedDoctor,
                providerId: providerId,
              ),
              const SizedBox(height: 16),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Upcoming Appointments',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary)),
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
                ...upcoming
                    .map((a) => _AppointmentCard(appt: a, isPast: false)),
              const SizedBox(height: 28),
              const Text('Past Appointments',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              if (past.isEmpty)
                _emptyCard(context,
                    icon: Icons.history, message: 'No past appointments')
              else
                ...past.map((a) => _AppointmentCard(appt: a, isPast: true)),
            ],
            if (!isConnected) ...[
              _NotConnectedBanner(),
              const SizedBox(height: 28),
              const Text('Find Your Doctor',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              const Text(
                'Choose how you\'d like to connect with a healthcare provider on AURA.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              _ConnectionPathCard(
                emoji: '🏥',
                title: 'Browse Partnered Specialists',
                subtitle:
                    'Connect with one of our verified AURA partner doctors across multiple specialties.',
                color: AppColors.primary,
                onTap: () => context.push(AppRoutes.partnerSpecialists),
              ),
              const SizedBox(height: 14),
              _ConnectionPathCard(
                emoji: '🔗',
                title: 'Connect With My Doctor',
                subtitle:
                    'Already see a doctor registered on AURA? Enter the Provider Code they shared with you.',
                color: Colors.teal,
                onTap: () => context.push(AppRoutes.connectDoctor),
              ),
            ],
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
          Icon(icon, size: 44, color: AppColors.textHint.withAlpha(120)),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub,
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}

class _ConnectedDoctorCard extends StatelessWidget {
  final PartnerDoctor? doctor;
  final String providerId;
  const _ConnectedDoctorCard({required this.doctor, required this.providerId});

  @override
  Widget build(BuildContext context) {
    final name = doctor?.name ?? 'Your Doctor';
    final specialty = doctor?.specialty ?? 'Healthcare Provider';
    final emoji = doctor?.emoji ?? '👨‍⚕️';

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
              color: AppColors.primary.withAlpha(60),
              blurRadius: 16,
              offset: const Offset(0, 8)),
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
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Text(specialty,
                    style: TextStyle(
                        color: Colors.white.withAlpha(200), fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('✅ Active',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    if (doctor?.availability != null) ...[
                      const SizedBox(width: 8),
                      Text(doctor!.availability,
                          style: TextStyle(
                              color: Colors.white.withAlpha(180),
                              fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (doctor?.rating != null)
            Column(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                Text(
                  doctor!.rating.toStringAsFixed(1),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NotConnectedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withAlpha(80)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_search_outlined,
                color: AppColors.warning, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('No Doctor Connected',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  'Connect with a doctor below to unlock messaging, appointments and health reports.',
                  style: TextStyle(
                      color: AppColors.textSecondary.withAlpha(200),
                      fontSize: 12,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionPathCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ConnectionPathCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60)),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: color)),
                  const SizedBox(height: 5),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

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
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

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
            child: const Center(
                child: Text('👨‍⚕️', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(appt['doctorName'] as String,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isPast
                            ? AppColors.textSecondary
                            : AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(dt),
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                if ((appt['note'] as String).isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(appt['note'] as String,
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
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
            child: Text(isPast ? 'Past' : 'Upcoming',
                style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
