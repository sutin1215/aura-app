import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class EditPeriodScreen extends StatefulWidget {
  const EditPeriodScreen({super.key});

  @override
  State<EditPeriodScreen> createState() => _EditPeriodScreenState();
}

class _EditPeriodScreenState extends State<EditPeriodScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _flow = 'Medium';
  String _mood = 'Neutral 😐';
  bool _isSaving = false;

  static const _flowOptions = ['Light', 'Medium', 'Heavy'];
  static const _moodOptions = [
    'Happy 😊',
    'Neutral 😐',
    'Sad 😔',
    'Irritable 😤',
    'Anxious 😰'
  ];

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.pinkAccent,
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E2E),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Period logged successfully!'),
          backgroundColor: Colors.pinkAccent,
        ),
      );
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) context.pop();
    }
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return 'Select date';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Period'),
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
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Text('🌸', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Log Your Period',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      const SizedBox(height: 4),
                      Text('Track your cycle accurately',
                          style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Dates ─────────────────────────────────────────────────
            _sectionLabel('Period Dates'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _dateBtn(
                    label: 'Start Date',
                    value: _fmtDate(_startDate),
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dateBtn(
                    label: 'End Date',
                    value: _fmtDate(_endDate),
                    icon: Icons.event_outlined,
                    onTap: () => _pickDate(false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Flow Intensity ─────────────────────────────────────────
            _sectionLabel('Flow Intensity'),
            const SizedBox(height: 12),
            Row(
              children: _flowOptions.map((opt) {
                final active = opt == _flow;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _flow = opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                          right: opt != _flowOptions.last ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: active ? Colors.pinkAccent : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color:
                                active ? Colors.pinkAccent : AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            opt == 'Light'
                                ? '🩸'
                                : opt == 'Medium'
                                    ? '🩸🩸'
                                    : '🩸🩸🩸',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(opt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Mood ──────────────────────────────────────────────────
            _sectionLabel('Mood'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _mood,
                  isExpanded: true,
                  items: _moodOptions
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _mood = v);
                  },
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Save ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Save Period Log',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: AppColors.textPrimary));

  Widget _dateBtn({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(icon, size: 16, color: Colors.pinkAccent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(value,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: value == 'Select date'
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
