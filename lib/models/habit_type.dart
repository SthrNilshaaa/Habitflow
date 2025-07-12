enum HabitType { fitness, mindfulness, productivity }

extension HabitTypeExtension on HabitType {
  String get displayName {
    switch (this) {
      case HabitType.fitness:
        return 'Fitness';
      case HabitType.mindfulness:
        return 'Mindfulness';
      case HabitType.productivity:
        return 'Productivity';
    }
  }
} 