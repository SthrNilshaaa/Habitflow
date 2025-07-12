import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/rive_animated_button.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final statistics = ref.read(habitProvider.notifier).getStatistics();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    void onAddHabit() {
      Navigator.pushNamed(context, '/add-habit');
    }

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
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 56.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: colorScheme.surface.withValues(alpha: isDark ? 0.18 : 0.13),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'HabitFlow',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        shadows: [
                          Shadow(
                            color: colorScheme.onSurface.withValues(alpha: 0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Statistics Overview
              if (habits.isNotEmpty) ...[
                _buildStatisticsOverview(statistics, isDark, colorScheme, context),
                const SizedBox(height: 16),
              ],
              
              habits.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.hourglass_empty, 
                              size: 80, 
                              color: colorScheme.primary.withValues(alpha: 0.3)
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No habits yet!',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RiveAnimatedButton(label: 'Add Habit', onTap: onAddHabit),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                        itemCount: habits.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, i) => HabitCard(
                          habit: habits[i],
                          onTap: () => Navigator.pushNamed(
                            context, 
                            '/habit-details',
                            arguments: habits[i],
                          ),
                          onComplete: () async {
                            await ref.read(habitProvider.notifier).markCompleted(
                              habits[i].id, 
                              DateTime.now(),
                            );
                          },
                          onDelete: () => _showDeleteDialog(context, ref, habits[i]),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsOverview(Map<String, dynamic> stats, bool isDark, ColorScheme colorScheme, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface.withValues(alpha: 0.15),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Active',
              '${stats['activeHabits']}',
              Icons.play_circle_outline,
              colorScheme.primary,
              isDark,
              colorScheme,
              context,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Completed Today',
              '${stats['completedToday']}',
              Icons.check_circle_outline,
              colorScheme.secondary,
              isDark,
              colorScheme,
              context,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Longest Streak',
              '${stats['longestStreak']}',
              Icons.local_fire_department,
              Colors.orange,
              isDark,
              colorScheme,
              context,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark, ColorScheme colorScheme, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic habit) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Delete Habit',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete "${habit.name}"?',
          style: TextStyle(color: colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(habitProvider.notifier).deleteHabit(habit.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
} 