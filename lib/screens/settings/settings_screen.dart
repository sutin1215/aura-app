import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _providerIdController = TextEditingController();
  bool _isLinking = false;
  bool _energySaving = false;

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
            backgroundColor: AppColors.success,
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Profile Summary ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white.withAlpha(50),
                  child:
                      const Icon(Icons.person, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.username ?? 'AURA User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Preferences ────────────────────────────────────────────────
          _sectionLabel('Preferences'),
          const SizedBox(height: 12),
          _menuCard(children: [
            _menuTile(
              icon: Icons.notifications_outlined,
              iconColor: AppColors.primary,
              title: 'Notifications',
              onTap: () => context.push(AppRoutes.notifSettings),
            ),
            _divider(),
            _menuTile(
              icon: Icons.language,
              iconColor: Colors.teal,
              title: 'Language Settings',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language support coming soon!')),
              ),
            ),
            _divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bolt, color: Colors.orange, size: 20),
              ),
              title: const Text('Energy Saving Mode',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: Switch(
                value: _energySaving,
                onChanged: (v) => setState(() => _energySaving = v),
                activeThumbColor: AppColors.primary,
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Support ────────────────────────────────────────────────────
          _sectionLabel('Support'),
          const SizedBox(height: 12),
          _menuCard(children: [
            _menuTile(
              icon: Icons.feedback_outlined,
              iconColor: Colors.deepPurple,
              title: 'Provide Feedback',
              onTap: () => context.push(AppRoutes.feedback),
            ),
            _divider(),
            _menuTile(
              icon: Icons.info_outline,
              iconColor: AppColors.info,
              title: 'About Us',
              onTap: () => context.push(AppRoutes.aboutUs),
            ),
          ]),

          const SizedBox(height: 24),

          // ── Healthcare Provider ────────────────────────────────────────
          _sectionLabel('Healthcare Provider'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
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
                  const SizedBox(height: 8),
                  const Text(
                    'To change provider, enter a new Provider ID below:',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                ] else ...[
                  const Text(
                    'Enter your healthcare provider\'s ID to link your data with them.',
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
                    onPressed:
                        _isLinking ? null : () => _linkToProvider(userId),
                    child: _isLinking
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Link Provider'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Account ────────────────────────────────────────────────────
          _sectionLabel('Account'),
          const SizedBox(height: 12),
          _menuCard(children: [
            ListTile(
              leading: _iconBox(Icons.email_outlined, AppColors.primary),
              title: const Text('Email',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(profile?.email ?? '',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
            _divider(),
            ListTile(
              leading: _iconBox(Icons.badge_outlined, AppColors.textSecondary),
              title: const Text('My User ID',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                userId.isNotEmpty ? userId : '...',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'monospace'),
              ),
              trailing: IconButton(
                icon:
                    const Icon(Icons.copy, size: 18, color: AppColors.primary),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: userId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User ID copied!')),
                  );
                },
              ),
            ),
            _divider(),
            ListTile(
              leading: _iconBox(Icons.lock_outline, Colors.orange),
              title: const Text('Change Password',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
              onTap: () => context.push(AppRoutes.changePassword),
            ),
            _divider(),
            ListTile(
              leading: _iconBox(Icons.logout, AppColors.error),
              title: const Text('Log Out',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.error)),
              onTap: () => auth.signOut(),
            ),
          ]),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      );

  Widget _menuCard({required List<Widget> children}) => Container(
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

  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: _iconBox(icon, iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.textHint),
        onTap: onTap,
      );

  Widget _iconBox(IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      );

  Widget _divider() => Divider(
      height: 1,
      indent: 56,
      endIndent: 20,
      color: AppColors.textHint.withAlpha(40));
}
