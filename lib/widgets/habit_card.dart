import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    final habitColors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colorScheme.surface.withValues(alpha: isDark ? 0.1 : 0.15),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Habit Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: habitColors[habit.colorIndex % habitColors.length].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getHabitIcon(habit.iconIndex),
                    color: habitColors[habit.colorIndex % habitColors.length],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Habit Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit.type,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak} day streak',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Action Buttons
                Column(
                  children: [
                    // Complete Button
                    if (onComplete != null)
                      IconButton(
                        onPressed: onComplete,
                        icon: Icon(
                          habit.isCompletedToday ? Icons.check_circle : Icons.circle_outlined,
                          color: habit.isCompletedToday 
                              ? Colors.green 
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        tooltip: habit.isCompletedToday ? 'Completed' : 'Mark as completed',
                      ),
                    
                    // Delete Button
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error.withValues(alpha: 0.7),
                        ),
                        tooltip: 'Delete habit',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getHabitIcon(int index) {
    final icons = [
      Icons.fitness_center,
      Icons.psychology,
      Icons.school,
      Icons.work,
      Icons.favorite,
      Icons.book,
      Icons.music_note,
      Icons.sports_soccer,
      Icons.restaurant,
      Icons.local_drink,
      Icons.bedtime,
      Icons.self_improvement,
    ];
    return icons[index % icons.length];
  }
} 