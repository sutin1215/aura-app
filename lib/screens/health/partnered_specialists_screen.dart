import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../data/partner_doctors.dart';

class PartnerSpecialistsScreen extends StatelessWidget {
  const PartnerSpecialistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partnered Specialists'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 12,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: [
                const Text('🏥', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AURA Partner Network',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Text(
                        'All doctors are verified AURA partners. Tap Connect to link your account.',
                        style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              itemCount: kPartnerDoctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) =>
                  _SpecialistCard(doctor: kPartnerDoctors[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  final PartnerDoctor doctor;
  const _SpecialistCard({required this.doctor});

  Color get _color {
    switch (doctor.specialty) {
      case 'General Practice':
        return AppColors.primary;
      case 'Cardiology':
        return AppColors.heartRate;
      case 'Endocrinology':
        return AppColors.warning;
      case 'Mental Health':
        return AppColors.sleep;
      case 'Nutrition & Dietetics':
        return AppColors.success;
      case 'Physiotherapy':
        return AppColors.steps;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withAlpha(40)),
        boxShadow: [
          BoxShadow(
              color: _color.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _color.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(doctor.emoji,
                        style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _color.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(doctor.specialty,
                          style: TextStyle(
                              color: _color,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 3),
                      Text(doctor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Available',
                        style: TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(doctor.bio,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
          const SizedBox(height: 12),
          Row(
            children: [
              _statChip(Icons.work_outline, '${doctor.experience} yrs',
                  AppColors.textSecondary),
              const SizedBox(width: 8),
              _statChip(Icons.calendar_today_outlined, doctor.availability,
                  AppColors.textSecondary),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  minimumSize: Size.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => _showConnectSheet(context, doctor),
                child: const Text('Connect',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) => Row(
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      );

  void _showConnectSheet(BuildContext context, PartnerDoctor doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => _ConnectConfirmSheet(
        doctor: doctor,
        onConfirm: () async {
          Navigator.pop(ctx);
          await _connect(context, doctor);
        },
      ),
    );
  }

  Future<void> _connect(BuildContext context, PartnerDoctor doctor) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.user?.uid;
    if (uid == null) return;

    try {
      await FirestoreService()
          .assignProvider(patientUid: uid, providerUid: doctor.hiddenUid);
      await auth.refreshProfile();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Connected to ${doctor.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _ConnectConfirmSheet extends StatelessWidget {
  final PartnerDoctor doctor;
  final VoidCallback onConfirm;

  const _ConnectConfirmSheet({required this.doctor, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint.withAlpha(60),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(doctor.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text('Connect with ${doctor.name}?',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            '${doctor.specialty} · ⭐ ${doctor.rating}',
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            'By connecting, ${doctor.name} will be able to view your health data, send you reports and message you through AURA.',
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Confirm Connection',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}
