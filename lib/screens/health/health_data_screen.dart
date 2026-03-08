import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  final _formKey = GlobalKey<FormState>();

  final _heartRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _oxygenController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _prefillFromFirestore();
  }

  Future<void> _prefillFromFirestore() async {
    final uid = Provider.of<AuthProvider>(context, listen: false).user?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final db = FirestoreService();
      await for (final day in db.streamTodayMetrics(uid).take(1)) {
        if (!mounted) return;
        setState(() {
          if (day.heartRate > 0) {
            _heartRateController.text = day.heartRate.toString();
          }
          if (day.weight > 0) {
            _weightController.text = day.weight.toStringAsFixed(1);
          }
          if (day.bloodPressureSystolic > 0) {
            _bpSystolicController.text = day.bloodPressureSystolic.toString();
          }
          if (day.bloodPressureDiastolic > 0) {
            _bpDiastolicController.text = day.bloodPressureDiastolic.toString();
          }
          if (day.bloodGlucose > 0) {
            _glucoseController.text = day.bloodGlucose.toStringAsFixed(1);
          }
          if (day.oxygenSaturation > 0) {
            _oxygenController.text = day.oxygenSaturation.toStringAsFixed(1);
          }
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _heartRateController.dispose();
    _weightController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _glucoseController.dispose();
    _oxygenController.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await FirestoreService().updateMetric(
        userId: user.uid,
        heartRate: int.tryParse(_heartRateController.text),
        weight: double.tryParse(_weightController.text),
        bloodPressureSystolic: int.tryParse(_bpSystolicController.text),
        bloodPressureDiastolic: int.tryParse(_bpDiastolicController.text),
        bloodGlucose: double.tryParse(_glucoseController.text),
        oxygenSaturation: double.tryParse(_oxygenController.text),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Health vitals saved!'),
              backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Health Vitals'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Info Banner ───────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🩺', style: TextStyle(fontSize: 30)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Daily Vitals',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(
                                    'Fields pre-filled from today\'s data. Update as needed.',
                                    style: TextStyle(
                                        color: Colors.white.withAlpha(200),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.error.withAlpha(80)),
                        ),
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: AppColors.error)),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Cardiovascular ────────────────────────────────
                    _sectionLabel('❤️  Cardiovascular', AppColors.heartRate),
                    const SizedBox(height: 12),
                    _card(children: [
                      _vitalField(
                        label: 'Heart Rate',
                        controller: _heartRateController,
                        suffix: 'bpm',
                        hint: '72',
                        icon: Icons.favorite_outline,
                        color: AppColors.heartRate,
                        isDouble: false,
                        range: '40–200',
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _vitalField(
                              label: 'BP Systolic',
                              controller: _bpSystolicController,
                              suffix: 'mmHg',
                              hint: '120',
                              icon: Icons.arrow_upward,
                              color: AppColors.primary,
                              isDouble: false,
                              range: '70–200',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _vitalField(
                              label: 'BP Diastolic',
                              controller: _bpDiastolicController,
                              suffix: 'mmHg',
                              hint: '80',
                              icon: Icons.arrow_downward,
                              color: AppColors.info,
                              isDouble: false,
                              range: '40–130',
                            ),
                          ),
                        ],
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Body Metrics ──────────────────────────────────
                    _sectionLabel('⚖️  Body Metrics', AppColors.weight),
                    const SizedBox(height: 12),
                    _card(children: [
                      _vitalField(
                        label: 'Weight',
                        controller: _weightController,
                        suffix: 'kg',
                        hint: '70.0',
                        icon: Icons.monitor_weight_outlined,
                        color: AppColors.weight,
                        isDouble: true,
                        range: '20–300',
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // ── Blood Work ────────────────────────────────────
                    _sectionLabel('🩸  Blood Work', Colors.orange),
                    const SizedBox(height: 12),
                    _card(children: [
                      _vitalField(
                        label: 'Blood Glucose',
                        controller: _glucoseController,
                        suffix: 'mg/dL',
                        hint: '95.0',
                        icon: Icons.water_drop_outlined,
                        color: Colors.orange,
                        isDouble: true,
                        range: '50–400',
                      ),
                      const SizedBox(height: 14),
                      _vitalField(
                        label: 'Oxygen Saturation (SpO₂)',
                        controller: _oxygenController,
                        suffix: '%',
                        hint: '98.0',
                        icon: Icons.air_outlined,
                        color: AppColors.water,
                        isDouble: true,
                        range: '80–100',
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // ── Save ──────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveData,
                        icon: _isSaving
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.save_outlined,
                                color: Colors.white),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Vitals',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionLabel(String text, Color color) => Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary)),
        ],
      );

  Widget _card({required List<Widget> children}) => Container(
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
          children: children,
        ),
      );

  Widget _vitalField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required String hint,
    required IconData icon,
    required Color color,
    required bool isDouble,
    required String range,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary)),
            const Spacer(),
            Text('Range: $range $suffix',
                style:
                    const TextStyle(color: AppColors.textHint, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            filled: true,
            fillColor: color.withAlpha(10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withAlpha(60)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withAlpha(40)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return null;
            final parsed =
                isDouble ? double.tryParse(value) : int.tryParse(value);
            if (parsed == null) return 'Enter a valid number';
            return null;
          },
        ),
      ],
    );
  }
}
