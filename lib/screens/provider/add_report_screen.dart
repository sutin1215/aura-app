import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class AddReportScreen extends StatefulWidget {
  final String patientUid;
  const AddReportScreen({super.key, required this.patientUid});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  int _categoryIndex = 0;
  bool _isSaving = false;

  static const _categories = [
    {
      'label': 'Check-up',
      'icon': Icons.health_and_safety_outlined,
      'color': 0xFF7B61FF
    },
    {
      'label': 'Lab Results',
      'icon': Icons.science_outlined,
      'color': 0xFF4CAF50
    },
    {
      'label': 'Prescription',
      'icon': Icons.medication_outlined,
      'color': 0xFFFF9800
    },
    {
      'label': 'Follow-up',
      'icon': Icons.event_repeat_outlined,
      'color': 0xFF6EC6F5
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a report title'),
            backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final cat = _categories[_categoryIndex]['label'] as String;
      await FirestoreService().addReport(
        patientUid: widget.patientUid,
        providerName: auth.userProfile?.username ?? 'Provider',
        title: '[$cat] $title',
        notes: _notesController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Report saved to patient record'),
              backgroundColor: AppColors.success),
        );
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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Report'),
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
            // ── Header Banner ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined,
                      color: Colors.white, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('New Clinical Report',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(
                          'Authored by ${auth.userProfile?.username ?? 'Provider'}',
                          style: TextStyle(
                              color: Colors.white.withAlpha(200), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Category ────────────────────────────────────────────────
            _sectionLabel('Report Category'),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_categories.length, (i) {
                final cat = _categories[i];
                final active = i == _categoryIndex;
                final color = Color(cat['color'] as int);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _categoryIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: active ? color : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: active ? color : AppColors.border),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                    color: color.withAlpha(60),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4))
                              ]
                            : [],
                      ),
                      child: Column(
                        children: [
                          Icon(cat['icon'] as IconData,
                              size: 20, color: active ? Colors.white : color),
                          const SizedBox(height: 4),
                          Text(
                            cat['label'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // ── Title ────────────────────────────────────────────────────
            _sectionLabel('Report Title'),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Monthly Blood Pressure Review',
                prefixIcon:
                    const Icon(Icons.title_outlined, color: AppColors.primary),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),

            const SizedBox(height: 20),

            // ── Notes ────────────────────────────────────────────────────
            _sectionLabel('Clinical Notes & Findings'),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 9,
              decoration: InputDecoration(
                hintText:
                    'Enter observations, test results, diagnoses, recommendations, medication changes, or follow-up instructions...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                filled: true,
                fillColor: AppColors.surface,
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // ── Info Note ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.info.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.info.withAlpha(60)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This report will be visible to the patient in their AURA app under Healthcare.',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Save Button ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, color: Colors.white),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Report',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary),
      );
}
