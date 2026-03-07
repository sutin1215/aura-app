import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EditPeriodScreen extends StatelessWidget {
  const EditPeriodScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Edit Period')),
        body: const Center(child: Text('Coming in Phase 5')),
      );
}
