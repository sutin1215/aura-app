import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/user_profile.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form State
  final _nameController = TextEditingController();
  String _gender = 'Not specified';
  DateTime? _dob;

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  final List<String> _commonConditions = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease',
    'None'
  ];
  final List<String> _selectedConditions = [];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  Future<void> _completeSetup() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) return;

    final profile = UserProfile(
      uid: user.uid,
      username: _nameController.text.trim().isEmpty ? 'AURA User' : _nameController.text.trim(),
      email: user.email ?? '',
      gender: _gender,
      dateOfBirth: _dob ?? DateTime.now(),
      height: double.tryParse(_heightController.text) ?? 170.0,
      weight: double.tryParse(_weightController.text) ?? 70.0,
      targetWeight: double.tryParse(_targetWeightController.text),
      healthConditions: _selectedConditions.isEmpty ? ['None'] : _selectedConditions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await auth.updateUserProfile(profile);
      // AppRouter auto-redirects after provider notifies listeners
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Setup Profile'),
        automaticallyImplyLeading: false, // Prevent going back to login
      ),
      body: Column(
        children: [
          // Step Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Force button nav
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildBioStep(),
                _buildMetricsStep(),
                _buildHealthConditionsStep(),
              ],
            ),
          ),

          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_currentPage > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == 2 ? 'Complete Setup' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who are you?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let\'s get to know the basics.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
          const Center(
             child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            label: 'Display Name',
            hint: 'How should we call you?',
            prefixIcon: Icons.person_outline,
            controller: _nameController,
          ),
          const SizedBox(height: 20),
          
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
          const SizedBox(height: 20),

          // DOB Picker
          GestureDetector(
             onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000),
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
        ],
      ),
    );
  }

  Widget _buildMetricsStep() {
     return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Body Metrics',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps AURA calculate accurate health goals like BMI and your daily Calorie target.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          
          CustomTextField(
            label: 'Height (cm)',
            hint: 'e.g., 175',
            prefixIcon: Icons.height,
            controller: _heightController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          
          CustomTextField(
            label: 'Current Weight (kg)',
            hint: 'e.g., 70.5',
            prefixIcon: Icons.monitor_weight_outlined,
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),

          CustomTextField(
            label: 'Target Goal Weight (kg) - Optional',
            hint: 'e.g., 65.0',
            prefixIcon: Icons.track_changes,
            controller: _targetWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthConditionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medical History',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select any pre-existing conditions so the Virtual Companion can tailor its advice.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          
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
        ],
      ),
    );
  }
}
