import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MenstrualScreen extends StatelessWidget {
  const MenstrualScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Menstrual Cycle')),
        body: const Center(child: Text('Coming in Phase 5')),
      );
}
