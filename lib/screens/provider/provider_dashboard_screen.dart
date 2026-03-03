import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_router.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final provider = auth.userProfile;
    final userId = auth.user?.uid ?? '';
    final db = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.primary,
              radius: 18,
              child: Icon(Icons.local_hospital, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Provider Portal', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  provider?.username ?? 'Provider',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Log Out',
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Provider info card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF6C63FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider?.specialty ?? 'Healthcare Provider',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const Text(
                        'My Patients',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'UID: ${userId.substring(0, 8)}...',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),

          // Patient list
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: db.streamPatientIds(userId),
              builder: (context, snapshot) {
                final patientIds = snapshot.data ?? [];

                if (patientIds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline, size: 80, color: AppColors.textHint.withAlpha(100)),
                        const SizedBox(height: 16),
                        const Text('No patients yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Patients link to you by entering your Patient ID (shown above) in their Settings.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: patientIds.length,
                  itemBuilder: (context, index) {
                    final patientUid = patientIds[index];
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: db.getPatientProfile(patientUid),
                      builder: (context, snap) {
                        final name = snap.data?['username'] ?? 'Loading...';
                        final conditions = List<String>.from(snap.data?['healthConditions'] ?? []);
                        return Card(
                          color: AppColors.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withAlpha(30),
                              child: const Icon(Icons.person, color: AppColors.primary),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            subtitle: conditions.isNotEmpty
                                ? Text(conditions.join(', '), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))
                                : const Text('No conditions listed', style: TextStyle(color: AppColors.textHint, fontSize: 12)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
                            onTap: () => context.push('${AppRoutes.providerPatientDetail}/$patientUid'),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
