import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _providerIdController = TextEditingController();
  bool _isLinking = false;

  @override
  void dispose() {
    _providerIdController.dispose();
    super.dispose();
  }

  Future<void> _linkToProvider(String patientUid) async {
    final providerId = _providerIdController.text.trim();
    if (providerId.isEmpty) return;

    setState(() => _isLinking = true);
    try {
      await FirestoreService().linkPatientToProvider(
        patientUid: patientUid,
        providerUid: providerId,
      );
      _providerIdController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Successfully linked to your provider!'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLinking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profile = auth.userProfile;
    final userId = auth.user?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Healthcare Provider ──────────────────────────────────────────────
          _sectionHeader('🏥 Healthcare Provider'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profile?.assignedProviderId != null) ...[
                  const Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Text('Linked to a provider',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provider UID: ${profile!.assignedProviderId!.substring(0, 12)}...',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'To change provider, enter the new Provider ID below:',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                ] else ...[
                  const Text(
                    'Enter your healthcare provider\'s ID to link your health data with them.',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _providerIdController,
                  decoration: InputDecoration(
                    labelText: 'Provider ID',
                    hintText: 'Paste the provider\'s UID here',
                    prefixIcon: const Icon(Icons.person_search,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed:
                        _isLinking ? null : () => _linkToProvider(userId),
                    child: _isLinking
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Link Provider',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Account ─────────────────────────────────────────────────────────
          _sectionHeader('👤 Account'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined,
                      color: AppColors.primary),
                  title: const Text('Email',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(profile?.email ?? '',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.copy, color: AppColors.primary),
                  title: const Text('My User ID',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    userId.isNotEmpty ? userId : '...',
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy,
                        size: 18, color: AppColors.primary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: userId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('User ID copied to clipboard')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── About ────────────────────────────────────────────────────────────
          _sectionHeader('ℹ️ About'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text('App Version',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('AURA Health v1.0.0 (Demo)'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Log Out',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: AppColors.error)),
                  onTap: () => auth.signOut(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textPrimary));
  }
}
