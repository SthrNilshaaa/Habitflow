import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/habit_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    if (habits.isEmpty) {
      return Stack(
        children: [
          // Custom animated glass background
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        colorScheme.surface.withValues(alpha: 0.4),
                        colorScheme.surface.withValues(alpha: 0.4),
                        colorScheme.primary.withValues(alpha: 0.1),
                      ]
                    : [
                        colorScheme.primary.withValues(alpha: 0.1),
                        colorScheme.secondary.withValues(alpha: 0.1),
                        colorScheme.surface.withValues(alpha: 0.8),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Container(
                color: isDark 
                    ? colorScheme.surface.withValues(alpha: 0.3)
                    : colorScheme.surface.withValues(alpha: 0.08),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(
                'Insights',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 80,
              titleSpacing: 16,
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics,
                    size: 80,
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No insights yet!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create some habits to see your insights',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final totalHabits = habits.length;
    final activeHabits = habits.where((h) => h.isActive).length;
    final completedToday = habits.where((h) => h.isCompletedToday).length;
    final totalCompletions = habits.fold<int>(0, (sum, h) => sum + h.history.length);
    final averageStreak = habits.isEmpty ? 0.0 : habits.map((h) => h.currentStreak).reduce((a, b) => a + b) / habits.length;

    return Stack(
      children: [
        // Custom animated glass background
        AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      colorScheme.surface.withValues(alpha: 0.4),
                      colorScheme.surface.withValues(alpha: 0.4),
                      colorScheme.primary.withValues(alpha: 0.1),
                    ]
                  : [
                      colorScheme.primary.withValues(alpha: 0.1),
                      colorScheme.secondary.withValues(alpha: 0.1),
                      colorScheme.surface.withValues(alpha: 0.8),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: isDark 
                  ? colorScheme.surface.withValues(alpha: 0.3)
                  : colorScheme.surface.withValues(alpha: 0.08),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              'Insights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            titleSpacing: 16,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview Stats
                _buildOverviewStats(
                  context,
                  totalHabits,
                  activeHabits,
                  completedToday,
                  totalCompletions,
                  averageStreak,
                  isDark,
                  colorScheme,
                ),
                const SizedBox(height: 16),
                
                // Top Performing Habits
                _buildTopPerformingHabits(context, habits, isDark, colorScheme),
                const SizedBox(height: 16),
                
                // Habit Types Distribution
                _buildHabitTypesDistribution(context, habits, isDark, colorScheme),
                const SizedBox(height: 16),
                
                // Weekly Progress
                _buildWeeklyProgress(context, habits, isDark, colorScheme),
                const SizedBox(height: 16),
                
                // Recommendations
                _buildRecommendations(context, habits, isDark, colorScheme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewStats(
    BuildContext context,
    int totalHabits,
    int activeHabits,
    int completedToday,
    int totalCompletions,
    double averageStreak,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Habits',
                  totalHabits.toString(),
                  Icons.list_alt,
                  colorScheme.primary,
                  isDark,
                  colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Active',
                  activeHabits.toString(),
                  Icons.play_circle,
                  Colors.green,
                  isDark,
                  colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Completed Today',
                  completedToday.toString(),
                  Icons.check_circle,
                  Colors.blue,
                  isDark,
                  colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Total Completions',
                  totalCompletions.toString(),
                  Icons.trending_up,
                  Colors.orange,
                  isDark,
                  colorScheme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Avg. Streak',
                  averageStreak.toStringAsFixed(1),
                  Icons.local_fire_department,
                  Colors.red,
                  isDark,
                  colorScheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color, bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface.withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingHabits(BuildContext context, List habits, bool isDark, ColorScheme colorScheme) {
    final sortedHabits = List.from(habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    final topHabits = sortedHabits.take(3).toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performing Habits',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (topHabits.isEmpty)
            Center(
              child: Text(
                'No habits yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            Column(
              children: topHabits.asMap().entries.map((entry) {
                final index = entry.key;
                final habit = entry.value;
                final colors = [Colors.amber, Colors.orange, Colors.red];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors[index],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          habit.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '${habit.currentStreak} days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHabitTypesDistribution(BuildContext context, List habits, bool isDark, ColorScheme colorScheme) {
    final typeCounts = <String, int>{};
    for (final habit in habits) {
      typeCounts[habit.type] = (typeCounts[habit.type] ?? 0) + 1;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Types',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (typeCounts.isEmpty)
            Center(
              child: Text(
                'No habits yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            Column(
              children: typeCounts.entries.map((entry) {
                final percentage = (entry.value / habits.length * 100).toStringAsFixed(1);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(BuildContext context, List habits, bool isDark, ColorScheme colorScheme) {
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return habits.where((habit) => habit.history.any((h) =>
          h.year == date.year &&
          h.month == date.month &&
          h.day == date.day)).length;
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekData.asMap().entries.map((entry) {
                final index = entry.key;
                final completed = entry.value;
                final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final maxCompletions = habits.length;

                return Column(
                  children: [
                    Container(
                      width: 30,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: maxCompletions > 0 ? (completed / maxCompletions * 60) : 0,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNames[index],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, List habits, bool isDark, ColorScheme colorScheme) {
    final recommendations = <String>[];
    
    if (habits.isEmpty) {
      recommendations.add('Start by creating your first habit');
    } else {
      final lowStreakHabits = habits.where((h) => h.currentStreak < 3).length;
      if (lowStreakHabits > 0) {
        recommendations.add('Focus on building consistency with $lowStreakHabits habit${lowStreakHabits > 1 ? 's' : ''}');
      }
      
      final completedToday = habits.where((h) => h.isCompletedToday).length;
      if (completedToday < habits.length) {
        recommendations.add('Complete ${habits.length - completedToday} more habit${(habits.length - completedToday) > 1 ? 's' : ''} today');
      }
      
      if (habits.length < 5) {
        recommendations.add('Consider adding more habits to build a comprehensive routine');
      }
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (recommendations.isEmpty)
            Center(
              child: Text(
                'Great job! Keep up the good work',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            Column(
              children: recommendations.map((recommendation) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
} 