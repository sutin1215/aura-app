import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  int _step = 1; // 1: Old PW, 2: OTP, 3: New PW
  bool _isLoading = false;

  final _oldPwController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  Future<void> _verifyOldPassword() async {
    if (_oldPwController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate check
    setState(() {
      _isLoading = false;
      _step = 2; // Move to OTP step
    });
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent to your email.'))
       );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length < 4) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate verify
    setState(() {
      _isLoading = false;
      _step = 3; // Move to New password
    });
  }

  Future<void> _setNewPassword() async {
    if (_newPwController.text.isEmpty || _confirmPwController.text.isEmpty) return;
    if (_newPwController.text != _confirmPwController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.error)
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2)); // simulate save
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Password changed successfully!'), backgroundColor: AppColors.success)
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Change Password'),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper indicator
            Row(
              children: [
                 _stepCircle(1, 'Verify'), _line(1),
                 _stepCircle(2, 'OTP'), _line(2),
                 _stepCircle(3, 'New'),
              ],
            ),
            const SizedBox(height: 48),

            if (_step == 1) ...[
               const Text('Enter Current Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
               const SizedBox(height: 8),
               const Text('Please enter your current password to proceed.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
               const SizedBox(height: 24),
               CustomTextField(
                 label: 'Current Password',
                 hint: '••••••••',
                 prefixIcon: Icons.lock_outline,
                 controller: _oldPwController,
                 isPassword: true,
               ),
               const SizedBox(height: 32),
               _buildButton('Send Verification Code', _verifyOldPassword),
            ] else if (_step == 2) ...[
               const Text('2-Step Verification', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
               const SizedBox(height: 8),
               const Text('We sent a 4-digit code to your email. Enter it below (Any 4 digits work for this demo).', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
               const SizedBox(height: 24),
               CustomTextField(
                 label: 'Verification Code',
                 hint: '0 0 0 0',
                 prefixIcon: Icons.mail_outline,
                 controller: _otpController,
                 keyboardType: TextInputType.number,
               ),
               const SizedBox(height: 32),
               _buildButton('Verify Code', _verifyOTP),
            ] else ...[
               const Text('Set New Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
               const SizedBox(height: 8),
               const Text('Choose a strong new password.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
               const SizedBox(height: 24),
               CustomTextField(
                 label: 'New Password',
                 hint: '••••••••',
                 prefixIcon: Icons.lock_outline,
                 controller: _newPwController,
                 isPassword: true,
               ),
               const SizedBox(height: 16),
               CustomTextField(
                 label: 'Confirm New Password',
                 hint: '••••••••',
                 prefixIcon: Icons.lock_reset,
                 controller: _confirmPwController,
                 isPassword: true,
               ),
               const SizedBox(height: 32),
               _buildButton('Save Password', _setNewPassword),
            ]
          ]
        )
      )
    );
  }

  Widget _stepCircle(int stepNum, String label) {
    final active = _step >= stepNum;
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: active ? null : Border.all(color: AppColors.textHint.withAlpha(50))
          ),
          child: Center(child: Text('$stepNum', style: TextStyle(color: active ? Colors.white : AppColors.textHint, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: active ? AppColors.primary : AppColors.textHint, fontWeight: FontWeight.bold))
      ],
    );
  }

  Widget _line(int stepNum) {
    final active = _step > stepNum;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        color: active ? AppColors.primary : AppColors.textHint.withAlpha(40),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
       width: double.infinity,
       child: ElevatedButton(
         style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
         ),
         onPressed: _isLoading ? null : onPressed,
         child: _isLoading 
           ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
           : Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
       ),
    );
  }
}
