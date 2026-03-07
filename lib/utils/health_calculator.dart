class HealthCalculator {
  /// Estimates calories burned based on sport type and duration.
  /// MET (Metabolic Equivalent of Task) values are used for estimation.
  static int estimateCalories({
    required String sportType,
    required int durationMinutes,
    double weightKg = 70.0,
  }) {
    double met = 1.0;
    switch (sportType.toLowerCase()) {
      case 'running':
        met = 9.8;
        break;
      case 'cycling':
        met = 7.5;
        break;
      case 'swimming':
        met = 8.0;
        break;
      case 'weightlifting':
        met = 5.0;
        break;
      case 'walking':
        met = 3.5;
        break;
      default:
        met = 4.0;
    }

    // Formula: Calories = MET * weight (kg) * duration (hours)
    return (met * weightKg * (durationMinutes / 60)).round();
  }

  /// Estimates steps added based on sport type and duration.
  static int estimateSteps({
    required String sportType,
    required int durationMinutes,
  }) {
    switch (sportType.toLowerCase()) {
      case 'running':
        return durationMinutes * 150;
      case 'walking':
        return durationMinutes * 100;
      case 'cycling':
        return durationMinutes * 40; // Low step count for cycling
      default:
        return 0;
    }
  }

  /// Calculates BMI
  static double calculateBMI(double heightCm, double weightKg) {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Gets BMI Category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
