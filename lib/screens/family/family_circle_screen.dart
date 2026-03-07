import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FamilyCircleScreen extends StatelessWidget {
  const FamilyCircleScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Family Circle')),
        body: const Center(child: Text('Coming in Phase 5')),
      );
}
