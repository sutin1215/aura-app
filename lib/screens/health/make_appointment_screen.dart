import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MakeAppointmentScreen extends StatelessWidget {
  const MakeAppointmentScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Make Appointment')),
        body: const Center(child: Text('Coming in Phase 4')),
      );
}
