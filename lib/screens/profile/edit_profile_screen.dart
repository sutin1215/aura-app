import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/user_profile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;
  
  // Form State
  late TextEditingController _nameController;
  late String _gender;
  DateTime? _dob;

  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;

  final List<String> _commonConditions = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease',
    'None'
  ];
  List<String> _selectedConditions = [];

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userProfile = auth.userProfile;

    // Pre-populate with existing data
    _nameController = TextEditingController(text: userProfile?.username ?? '');
    _gender = userProfile?.gender ?? 'Not specified';
    _dob = userProfile?.dateOfBirth;

    _heightController = TextEditingController(text: userProfile?.height.toString() ?? '');
    _weightController = TextEditingController(text: userProfile?.weight.toString() ?? '');
    
    final target = userProfile?.targetWeight;
    _targetWeightController = TextEditingController(text: target != null ? target.toString() : '');

    _selectedConditions = userProfile?.healthConditions.toList() ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final existingProfile = auth.userProfile;
    
    if (user == null || existingProfile == null) return;

    final updatedProfile = UserProfile(
      uid: existingProfile.uid,
      username: _nameController.text.trim().isEmpty ? 'AURA User' : _nameController.text.trim(),
      email: existingProfile.email,
      gender: _gender,
      dateOfBirth: _dob ?? DateTime.now(),
      height: double.tryParse(_heightController.text) ?? existingProfile.height,
      weight: double.tryParse(_weightController.text) ?? existingProfile.weight,
      targetWeight: double.tryParse(_targetWeightController.text),
      healthConditions: _selectedConditions.isEmpty ? ['None'] : _selectedConditions,
      createdAt: existingProfile.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await auth.updateUserProfile(updatedProfile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
        );
        context.pop(); // Go back to profile screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bio Section
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Display Name',
              hint: 'John Doe',
              prefixIcon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            
            // Gender Dropdown
            Container(
               decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textHint.withAlpha(50)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _gender,
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint),
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: ['Not specified', 'Male', 'Female', 'Other']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      if (newValue != null) _gender = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DOB Picker
            GestureDetector(
               onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dob ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primary,
                            surface: AppColors.surface,
                          ),
                        ),
                        child: child!,
                      );
                    }
                  );
                  if (date != null) {
                     setState(() => _dob = date);
                  }
               },
               child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.textHint.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.textHint, size: 20),
                      const SizedBox(width: 12),
                      Text(
                         _dob == null ? 'Date of Birth' : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                         style: TextStyle(
                           color: _dob == null ? AppColors.textHint : AppColors.textPrimary,
                           fontSize: 16,
                         ),
                      ),
                    ],
                  ),
               ),
            ),
            
            const SizedBox(height: 40),

            // Body Metrics Section
            Text(
              'Body Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Height (cm)',
              hint: 'e.g., 175',
              prefixIcon: Icons.height,
              controller: _heightController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Current Weight (kg)',
              hint: 'e.g., 70.5',
              prefixIcon: Icons.monitor_weight_outlined,
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Target Goal Weight (kg) - Optional',
              hint: 'e.g., 65.0',
              prefixIcon: Icons.track_changes,
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),

            const SizedBox(height: 40),

            // Medical History
            Text(
              'Medical History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 12.0,
              children: _commonConditions.map((condition) {
                final isSelected = _selectedConditions.contains(condition);
                return FilterChip(
                  label: Text(condition),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (condition == 'None') {
                        if (selected) {
                          _selectedConditions.clear();
                          _selectedConditions.add('None');
                        } else {
                          _selectedConditions.remove('None');
                        }
                      } else {
                        _selectedConditions.remove('None');
                        if (selected) {
                          _selectedConditions.add(condition);
                        } else {
                          _selectedConditions.remove(condition);
                        }
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withAlpha(50),
                  checkmarkColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.textHint.withAlpha(50),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
