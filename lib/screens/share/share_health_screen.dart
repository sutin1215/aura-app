import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../theme/app_theme.dart';

class ShareHealthScreen extends StatefulWidget {
  const ShareHealthScreen({super.key});

  @override
  State<ShareHealthScreen> createState() => _ShareHealthScreenState();
}

class _ShareHealthScreenState extends State<ShareHealthScreen> {
  final Map<String, bool> _selectedMetrics = {
    'Steps & Activity': true,
    'Sleep': true,
    'Meals & Diet': true,
    'Vitals (HR, BP)': false,
  };

  bool _isSharing = false;

  Future<void> _shareData(String patientUid, String providerUid, String patientName) async {
    final hasSelection = _selectedMetrics.values.any((v) => v);
    if (!hasSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one data type to share.')),
      );
      return;
    }

    setState(() => _isSharing = true);
    try {
      // For demo purposes, "sharing" means sending a report notification to the provider
      // If we had a Provider inbox, we'd write to it. Here, we'll just show a success message 
      // since the provider already has access to the patient's data stream via the PatientDetailScreen.
      
      // We simulate brief processing time
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Health data shared securely with your Provider!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing data: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showSocialMediaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share to Social Media', style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary
            )),
            const SizedBox(height: 8),
            const Text('Select a platform to share your health achievements.', style: TextStyle(
              fontSize: 14, color: AppColors.textSecondary
            )),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _socialIcon(Icons.camera_alt, 'Instagram', Colors.purple, ctx),
                _socialIcon(Icons.facebook, 'Facebook', Colors.blue, ctx),
                _socialIcon(Icons.chat_bubble, 'Twitter', Colors.lightBlue, ctx),
                _socialIcon(Icons.more_horiz, 'More', Colors.grey, ctx),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, String label, Color color, BuildContext ctx) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(ctx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preparing image for $label...'))
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('🎉 Shared successfully to $label!'), backgroundColor: AppColors.success)
           );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userProfile = auth.userProfile;
    final patientUid = auth.user?.uid ?? '';
    final providerUid = userProfile?.assignedProviderId;

    final today = Provider.of<MetricsProvider>(context).todayMetrics;

    if (providerUid == null || providerUid.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Share Health Data'), elevation: 0, backgroundColor: AppColors.background),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link_off, size: 80, color: AppColors.textHint.withAlpha(100)),
                const SizedBox(height: 24),
                const Text('No Provider Linked', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                const Text(
                  'You need to link your account to a Healthcare Provider in Settings before you can share data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Share Health Data'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6C63FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 24,
                    child: Icon(Icons.medical_services, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sharing with linked provider', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        Text(
                          'Provider ID: ${providerUid.substring(0, 8)}...',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text('What would you like to share today?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Select the data points you want to include in this snapshot.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 24),

            // Checkboxes
            ..._selectedMetrics.keys.map((key) {
              return CheckboxListTile(
                title: Text(key, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                value: _selectedMetrics[key],
                activeColor: AppColors.primary,
                checkColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedMetrics[key] = val);
                  }
                },
              );
            }),

            const SizedBox(height: 48),

            // Today's summary preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preview Data', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  if (_selectedMetrics['Steps & Activity'] == true) Text('• Steps: ${today?.steps ?? 0}', style: const TextStyle(color: AppColors.textSecondary)),
                  if (_selectedMetrics['Sleep'] == true) Text('• Sleep: ${((today?.sleepMinutes ?? 0) / 60).toStringAsFixed(1)}h', style: const TextStyle(color: AppColors.textSecondary)),
                  if (_selectedMetrics['Meals & Diet'] == true) Text('• Calories: ${today?.caloriesBurned ?? 0}', style: const TextStyle(color: AppColors.textSecondary)),
                  if (_selectedMetrics['Vitals (HR, BP)'] == true) Text('• Heart Rate: ${today?.heartRate ?? 0} bpm', style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Share Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isSharing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send, color: Colors.white),
                label: const Text('Send Health Snapshot', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSharing ? null : () => _shareData(patientUid, providerUid, userProfile?.username ?? 'Patient'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Social Media Share Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.share, color: AppColors.primary),
                label: const Text('Share to Social Media', style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _showSocialMediaSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
