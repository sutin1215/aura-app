import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_router.dart';

const _avatarColors = [
  Color(0xFF7B61FF),
  Color(0xFF4CAF50),
  Color(0xFFFF6B6B),
  Color(0xFF6EC6F5),
  Color(0xFFFFC107),
  Color(0xFFFF9800),
];

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profile = auth.userProfile;
    final userId = auth.user?.uid ?? '';
    final greeting = _greeting();
    final db = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(60),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (profile?.username ?? 'P')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greeting,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                            Text(
                              profile?.username ?? 'Doctor',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                            if ((profile?.specialty ?? '').isNotEmpty)
                              Text(
                                profile!.specialty!,
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout,
                            color: AppColors.error, size: 22),
                        tooltip: 'Log Out',
                        onPressed: () => _confirmLogout(context, auth),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // This is the updated Gradient Banner with QR button
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.medical_services,
                            color: Colors.white, size: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Provider Portal',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                'Share your QR code with patients to connect',
                                style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showQrSheet(context, profile, userId),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.qr_code_2,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 6),
                                Text('My QR',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'My Patients',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      StreamBuilder<List<String>>(
                        stream: db.streamPatientIds(userId),
                        builder: (context, snap) {
                          final count = snap.data?.length ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count patient${count == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: db.streamPatientIds(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final patientIds = snapshot.data ?? [];

                  if (patientIds.isEmpty) {
                    return _emptyState(context, userId);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                    itemCount: patientIds.length,
                    itemBuilder: (context, index) {
                      final patientUid = patientIds[index];
                      final color = _avatarColors[index % _avatarColors.length];
                      return _PatientCard(
                        patientUid: patientUid,
                        avatarColor: color,
                        db: db,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _emptyState(BuildContext context, String userId) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.people_outline,
                size: 64, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Patients Yet',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap "My QR" to share your Code with patients.\nThey enter it in their app to link up with you.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textSecondary, height: 1.6, fontSize: 14),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
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

  // Adding the requested method to this stateless widget class
  void _showQrSheet(BuildContext context, profile, String userId) {
    String providerCode;
    if (profile?.username != null && profile.username.isNotEmpty) {
      final parts = (profile.username as String).trim().split(' ');
      final lastName = parts.length > 1 ? parts.last : parts.first;
      providerCode =
          '${lastName.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '')}-2024';
    } else {
      providerCode = userId.substring(0, 8).toUpperCase();
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 48),
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
            const Text('Your Provider QR Code',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Show this to your patients so they can connect\nwith you on AURA.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withAlpha(30),
                      blurRadius: 20,
                      offset: const Offset(0, 8)),
                ],
              ),
              child: QrImageView(
                data: providerCode,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.primary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.vpn_key_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    providerCode,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: providerCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Provider code copied!'),
                            backgroundColor: AppColors.success),
                      );
                    },
                    child: const Icon(Icons.copy,
                        size: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Patients can also type this code manually\nin the AURA patient app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textHint, fontSize: 12, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final String patientUid;
  final Color avatarColor;
  final FirestoreService db;

  const _PatientCard({
    required this.patientUid,
    required this.avatarColor,
    required this.db,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: db.getPatientProfile(patientUid),
      builder: (context, snap) {
        final name = snap.data?['username'] ?? 'Loading...';
        final email = snap.data?['email'] ?? '';
        final conditions =
            List<String>.from(snap.data?['healthConditions'] ?? []);
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return GestureDetector(
          onTap: () =>
              context.push('${AppRoutes.providerPatientDetail}/$patientUid'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 12,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: avatarColor.withAlpha(80),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary)),
                      if (email.isNotEmpty)
                        Text(email,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      if (conditions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            spacing: 4,
                            children: conditions
                                .take(2)
                                .map((c) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: avatarColor.withAlpha(20),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(c,
                                          style: TextStyle(
                                              color: avatarColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    _iconBtn(
                      Icons.chat_bubble_outline,
                      AppColors.primary,
                      () async {
                        final patientName = (await db
                                .getPatientProfile(patientUid))?['username'] ??
                            'Patient';
                        if (context.mounted) {
                          context.push(Uri(
                            path:
                                '${AppRoutes.providerChatPatient}/$patientUid',
                            queryParameters: {'name': patientName},
                          ).toString());
                        }
                      },
                    ),
                    const SizedBox(height: 6),
                    _iconBtn(
                      Icons.arrow_forward_ios,
                      AppColors.textHint,
                      () => context.push(
                          '${AppRoutes.providerPatientDetail}/$patientUid'),
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap,
      {double size = 18}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
