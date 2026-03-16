import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../models/user_profile.dart';

// ── Master conditions list ─────────────────────────────────────────────────────
// Organised by category so the search also surfaces category names.
const _allConditions = [
  // Cardiovascular
  'Hypertension (High Blood Pressure)',
  'Hypotension (Low Blood Pressure)',
  'Coronary Artery Disease',
  'Heart Failure',
  'Atrial Fibrillation',
  'Heart Attack (Myocardial Infarction)',
  'Stroke',
  'Deep Vein Thrombosis (DVT)',
  'Peripheral Artery Disease',
  'High Cholesterol (Hyperlipidaemia)',

  // Metabolic & Endocrine
  'Type 1 Diabetes',
  'Type 2 Diabetes',
  'Pre-Diabetes',
  'Obesity',
  'Hypothyroidism',
  'Hyperthyroidism',
  'Polycystic Ovary Syndrome (PCOS)',
  'Metabolic Syndrome',
  'Gout',
  'Vitamin D Deficiency',

  // Respiratory
  'Asthma',
  'Chronic Obstructive Pulmonary Disease (COPD)',
  'Chronic Bronchitis',
  'Emphysema',
  'Sleep Apnoea',
  'Pulmonary Hypertension',
  'Tuberculosis (TB)',
  'Allergic Rhinitis (Hay Fever)',

  // Digestive & Gastrointestinal
  'Gastroesophageal Reflux Disease (GERD)',
  'Irritable Bowel Syndrome (IBS)',
  'Crohn\'s Disease',
  'Ulcerative Colitis',
  'Coeliac Disease',
  'Peptic Ulcer',
  'Liver Cirrhosis',
  'Non-Alcoholic Fatty Liver Disease (NAFLD)',
  'Gallstones',
  'Haemorrhoids',

  // Musculoskeletal
  'Osteoarthritis',
  'Rheumatoid Arthritis',
  'Osteoporosis',
  'Gout',
  'Fibromyalgia',
  'Scoliosis',
  'Chronic Back Pain',
  'Lupus (Systemic Lupus Erythematosus)',

  // Neurological & Mental Health
  'Migraine',
  'Epilepsy',
  'Parkinson\'s Disease',
  'Multiple Sclerosis',
  'Alzheimer\'s Disease / Dementia',
  'Anxiety Disorder',
  'Depression',
  'Bipolar Disorder',
  'Attention Deficit Hyperactivity Disorder (ADHD)',
  'Obsessive-Compulsive Disorder (OCD)',
  'Post-Traumatic Stress Disorder (PTSD)',

  // Renal & Urological
  'Chronic Kidney Disease',
  'Kidney Stones',
  'Urinary Tract Infections (Recurrent)',
  'Benign Prostatic Hyperplasia (BPH)',

  // Haematological
  'Anaemia (Iron Deficiency)',
  'Sickle Cell Disease',
  'Thalassaemia',
  'Haemophilia',
  'Leukaemia',

  // Skin
  'Psoriasis',
  'Eczema (Atopic Dermatitis)',
  'Acne (Severe)',
  'Rosacea',

  // Immune & Infectious
  'HIV / AIDS',
  'Hepatitis B',
  'Hepatitis C',
  'Autoimmune Thyroiditis (Hashimoto\'s)',

  // Cancer (common)
  'Breast Cancer',
  'Lung Cancer',
  'Colorectal Cancer',
  'Prostate Cancer',
  'Skin Cancer (Melanoma)',

  // Eyes & ENT
  'Glaucoma',
  'Cataracts',
  'Macular Degeneration',
  'Hearing Loss',

  // Reproductive
  'Endometriosis',
  'Menopause-related Conditions',
  'Erectile Dysfunction',
];

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page 1 — Bio
  final _nameController = TextEditingController();
  String _gender = 'Not specified';
  DateTime? _dob;

  // Page 2 — Metrics
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  // Page 3 — Medical History
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final List<String> _selectedConditions = [];
  bool _noneSelected = false;

  List<String> get _filteredConditions {
    if (_searchQuery.isEmpty) return _allConditions;
    final q = _searchQuery.toLowerCase();
    return _allConditions.where((c) => c.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      FocusScope.of(context).unfocus();
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

    final conditions = _noneSelected || _selectedConditions.isEmpty
        ? ['None']
        : _selectedConditions;

    final profile = UserProfile(
      uid: user.uid,
      username: _nameController.text.trim().isEmpty
          ? 'AURA User'
          : _nameController.text.trim(),
      email: user.email ?? '',
      gender: _gender,
      dateOfBirth: _dob ?? DateTime.now(),
      height: double.tryParse(_heightController.text) ?? 170.0,
      weight: double.tryParse(_weightController.text) ?? 70.0,
      targetWeight: double.tryParse(_targetWeightController.text),
      healthConditions: conditions,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await auth.updateUserProfile(profile);
      // AppRouter auto-redirects after provider notifies listeners
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: AppColors.error),
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
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Step dots ──────────────────────────────────────────────────
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
                    color: _currentPage >= index
                        ? AppColors.primary
                        : AppColors.textHint.withAlpha(80),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildBioStep(),
                _buildMetricsStep(),
                _buildHealthConditionsStep(),
              ],
            ),
          ),

          // ── Navigation buttons ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_currentPage > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
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

  // ── Page 1: Bio ─────────────────────────────────────────────────────────────
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
            "Let's get to know the basics.",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.surface,
              child:
                  Icon(Icons.add_a_photo, size: 40, color: AppColors.primary),
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

          // Gender
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
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textHint),
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                items: ['Not specified', 'Male', 'Female', 'Other']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _gender = v);
                },
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Date of birth
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _dob = date);
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
                  const Icon(Icons.calendar_today,
                      color: AppColors.textHint, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _dob == null
                        ? 'Date of Birth'
                        : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                    style: TextStyle(
                      color: _dob == null
                          ? AppColors.textHint
                          : AppColors.textPrimary,
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

  // ── Page 2: Metrics ─────────────────────────────────────────────────────────
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
            'This helps AURA calculate your BMI and daily calorie target accurately.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          CustomTextField(
            label: 'Height (cm)',
            hint: 'e.g. 175',
            prefixIcon: Icons.height,
            controller: _heightController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Current Weight (kg)',
            hint: 'e.g. 70.5',
            prefixIcon: Icons.monitor_weight_outlined,
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Target Weight (kg) — Optional',
            hint: 'e.g. 65.0',
            prefixIcon: Icons.track_changes,
            controller: _targetWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  // ── Page 3: Medical History ─────────────────────────────────────────────────
  Widget _buildHealthConditionsStep() {
    final filtered = _filteredConditions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
              const SizedBox(height: 6),
              const Text(
                'Select any pre-existing conditions so AURA can tailor advice for you. You can skip this if you have none.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),

              // ── Search bar ───────────────────────────────────────────
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search conditions...',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textHint),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textHint, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 12),

              // ── Selected chips summary ───────────────────────────────
              if (_selectedConditions.isNotEmpty || _noneSelected)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (_noneSelected) _selectedChip('None'),
                    ..._selectedConditions.map(_selectedChip),
                  ],
                ),

              if (_selectedConditions.isNotEmpty || _noneSelected)
                const SizedBox(height: 12),
            ],
          ),
        ),

        // ── "None of the above" row + count label ────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _noneSelected = !_noneSelected;
                    if (_noneSelected) _selectedConditions.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: _noneSelected
                          ? AppColors.success.withAlpha(20)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _noneSelected
                            ? AppColors.success
                            : AppColors.textHint.withAlpha(60),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _noneSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: _noneSelected
                              ? AppColors.success
                              : AppColors.textHint,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'None of the above',
                          style: TextStyle(
                            color: _noneSelected
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: _noneSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_selectedConditions.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedConditions.length} selected',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),

        // ── Scrollable conditions list ───────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 48, color: AppColors.textHint.withAlpha(120)),
                      const SizedBox(height: 12),
                      Text(
                        'No results for "$_searchQuery"',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final condition = filtered[index];
                    final isSelected = _selectedConditions.contains(condition);

                    return GestureDetector(
                      onTap: _noneSelected
                          ? null
                          : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedConditions.remove(condition);
                                } else {
                                  _selectedConditions.add(condition);
                                }
                              });
                            },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(15)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textHint.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                condition,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : _noneSelected
                                          ? AppColors.textHint
                                          : AppColors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppColors.primary, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _selectedChip(String label) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedConditions.remove(label);
        if (label == 'None') _noneSelected = false;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.close, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}
