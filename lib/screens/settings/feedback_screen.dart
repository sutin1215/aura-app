import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Provide Feedback')),
        body: const Center(child: Text('Coming in Phase 5')),
      );
}
