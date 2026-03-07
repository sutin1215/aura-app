import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HealthcareInteractionScreen extends StatelessWidget {
  const HealthcareInteractionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Healthcare')),
        body: const Center(child: Text('Coming in Phase 4')),
      );
}
