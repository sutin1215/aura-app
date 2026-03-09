import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';
import '../../data/partner_doctors.dart';

class ConnectDoctorScreen extends StatefulWidget {
  const ConnectDoctorScreen({super.key});

  @override
  State<ConnectDoctorScreen> createState() => _ConnectDoctorScreenState();
}

class _ConnectDoctorScreenState extends State<ConnectDoctorScreen> {
  final _codeController = TextEditingController();
  PartnerDoctor? _foundDoctor;
  bool _searched = false;
  bool _isConnecting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _search() {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    final doctor = doctorByCode(code);
    setState(() {
      _foundDoctor = doctor;
      _searched = true;
    });
  }

  Future<void> _connect() async {
    if (_foundDoctor == null) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.user?.uid;
    if (uid == null) return;

    setState(() => _isConnecting = true);
    try {
      await FirestoreService().assignProvider(
          patientUid: uid, providerUid: _foundDoctor!.hiddenUid);
      await auth.refreshProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Connected to ${_foundDoctor!.name}!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Connect With My Doctor'),
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
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.teal.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.withAlpha(60)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🔗', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('How does this work?',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        const Text(
                          'Your doctor will share a Provider Code or QR code from their AURA provider app. Enter that code below to link your account to them.',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Enter Provider Code',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'e.g. KANG-2024',
                      prefixIcon: const Icon(Icons.vpn_key_outlined,
                          color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(56, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: _search,
                  child:
                      const Icon(Icons.search, color: Colors.white, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      '📷 QR scanning coming soon! Please enter the code manually for now.'),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withAlpha(60)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner,
                        color: AppColors.primary, size: 22),
                    SizedBox(width: 10),
                    Text('Scan Doctor\'s QR Code',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            if (_searched) ...[
              if (_foundDoctor != null)
                _DoctorResultCard(
                  doctor: _foundDoctor!,
                  isConnecting: _isConnecting,
                  onConnect: _connect,
                )
              else
                _NotFoundCard(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _DoctorResultCard extends StatelessWidget {
  final PartnerDoctor doctor;
  final bool isConnecting;
  final VoidCallback onConnect;

  const _DoctorResultCard({
    required this.doctor,
    required this.isConnecting,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withAlpha(80)),
        boxShadow: [
          BoxShadow(
              color: AppColors.success.withAlpha(20),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.success, size: 16),
                SizedBox(width: 6),
                Text('Doctor found on AURA!',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                    child: Text(doctor.emoji,
                        style: const TextStyle(fontSize: 30))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(doctor.specialty,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(doctor.rating.toStringAsFixed(1),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 10),
                        Text('${doctor.experience} yrs exp',
                            style: const TextStyle(
                                color: AppColors.textHint, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(doctor.bio,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.5),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isConnecting ? null : onConnect,
              icon: isConnecting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.link, color: Colors.white),
              label: Text(
                  isConnecting
                      ? 'Connecting...'
                      : 'Connect with ${doctor.name}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotFoundCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withAlpha(60)),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          const Text('Code Not Found',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          const Text(
            'This Provider Code isn\'t registered on AURA. Please double-check with your doctor.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      '📧 Invite sent! Your doctor will receive an email about AURA.')),
            ),
            icon: const Icon(Icons.mail_outline, size: 18),
            label: const Text('Invite My Doctor to AURA'),
            style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
          ),
        ],
      ),
    );
  }
}
