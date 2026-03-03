import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/metrics_provider.dart';
import '../../services/firestore_service.dart';
import '../../theme/app_theme.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _selectedMealType = 'Breakfast';
  bool _isSaving = false;

  static const List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snacks'];
  static const List<String> _mealEmojis = ['🍳', '🍔', '🍷', '🍪'];

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _logMeal(String userId) async {
    final foodName = _foodNameController.text.trim();
    final int? cal = int.tryParse(_caloriesController.text.trim());

    if (foodName.isEmpty || cal == null || cal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food name and calories'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await FirestoreService().addMeal(
        userId: userId,
        mealType: _selectedMealType,
        foodName: foodName,
        calories: cal,
      );
      _foodNameController.clear();
      _caloriesController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$foodName logged! +$cal kcal'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteMeal(String userId, Map<String, dynamic> entry) async {
    try {
      await FirestoreService().deleteMeal(
        userId: userId,
        entryId: entry['id'],
        calories: entry['calories'] ?? 0,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.uid ?? '';
    final metricsProvider = Provider.of<MetricsProvider>(context);
    final today = metricsProvider.todayMetrics;

    const int dailyCalGoal = 2000;
    final int currentCal = today?.caloriesBurned ?? 0;
    final double progress = (currentCal / dailyCalGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nutrition Log'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),

            // Calorie Progress Ring
            Center(
              child: CircularPercentIndicator(
                radius: 110.0,
                lineWidth: 18.0,
                percent: progress,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: AppColors.surface,
                progressColor: AppColors.calories,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${currentCal}kcal',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    const Text('of $dailyCalGoal kcal', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Log Meal Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Meal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                  const SizedBox(height: 16),

                  // Meal Type Buttons
                  Wrap(
                    spacing: 8,
                    children: List.generate(_mealTypes.length, (i) {
                      final isSelected = _selectedMealType == _mealTypes[i];
                      return ChoiceChip(
                        label: Text('${_mealEmojis[i]} ${_mealTypes[i]}'),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedMealType = _mealTypes[i]),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      prefixIcon: const Icon(Icons.restaurant, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Calories (kcal)',
                      prefixIcon: const Icon(Icons.local_fire_department, color: AppColors.calories),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _isSaving ? null : () => _logMeal(userId),
                      child: _isSaving
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Log Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Today's Meal List
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService().streamTodayMeals(userId),
              builder: (context, snapshot) {
                final meals = snapshot.data ?? [];
                if (meals.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                    child: const Center(
                      child: Text(
                        'No meals logged yet today.\nAdd your first meal above!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                // Group by meal type
                final grouped = <String, List<Map<String, dynamic>>>{};
                for (final meal in meals) {
                  final type = meal['mealType'] as String? ?? 'Other';
                  grouped.putIfAbsent(type, () => []).add(meal);
                }

                return Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Text("Today's Meals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      ),
                      for (final type in _mealTypes)
                        if (grouped.containsKey(type)) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                            child: Text(
                              type,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                          ...grouped[type]!.map((meal) => ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: AppColors.calories,
                                  child: Icon(Icons.fastfood, color: Colors.white, size: 18),
                                ),
                                title: Text(meal['foodName'] ?? 'Food', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${meal['calories']} kcal'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () => _deleteMeal(userId, meal),
                                ),
                              )),
                        ],
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
