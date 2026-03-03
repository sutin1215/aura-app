class Goal {
  final String id;
  final String name;       // e.g. 'Daily Steps'
  final String metric;     // 'steps' | 'waterIntakeMl' | 'caloriesBurned' | 'sleepMinutes' | 'weight'
  final double target;     // target value
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.name,
    required this.metric,
    required this.target,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'metric': metric,
        'target': target,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromMap(Map<String, dynamic> data, String id) => Goal(
        id: id,
        name: data['name'] ?? '',
        metric: data['metric'] ?? 'steps',
        target: (data['target'] ?? 0).toDouble(),
        createdAt: data['createdAt'] != null
            ? DateTime.parse(data['createdAt'])
            : DateTime.now(),
      );
}
