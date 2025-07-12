import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitflow/screens/add_edit_habit_screen.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../widgets/rive_animated_button.dart';
import 'dart:ui';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback? onAddHabit;
  final void Function(dynamic habit)? onHabitTap;
  const DashboardScreen({super.key, this.onAddHabit, this.onHabitTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statistics = ref.read(habitProvider.notifier).getStatistics();
    
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
                      const Color(0x66121212),
                      const Color(0x661E1E1E),
                      const Color(0x66242424),
                    ]
                  : const [
                      Color(0x66A1C4FD),
                      Color(0x66FBC2EB),
                      Color(0x66FDC2FB),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 45.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDark 
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'HabitFlow',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.95)
                            : Colors.black.withValues(alpha: 0.92),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.08),
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
                _buildStatisticsOverview(statistics, isDark),
                const SizedBox(height: 20),
              ],
              
              habits.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hourglass_empty, size: 80, color: Colors.blueAccent.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No habits yet!',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            RiveAnimatedButton(label: 'Add Habit', onTap: () {
                              Navigator.pushNamed(context, '/add-habit');
                            }),
                            ],
                        ),
                      ),
                    )
                  : Expanded(
                      
                      child: ListView.builder(
                        
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        
                        itemCount: habits.length,
                       // separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 70),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsOverview(Map<String, dynamic> stats, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:isDark?Colors.white.withValues(alpha: 0.08):Colors.white.withValues(alpha: 0.30), 
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Active',
              '${stats['activeHabits']}',
              Icons.play_circle_outline,
              Colors.green,
              isDark,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Completed Today',
              '${stats['completedToday']}',
              Icons.check_circle_outline,
              Colors.blue,
              isDark,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Longest Streak',
              '${stats['longestStreak']}',
              Icons.local_fire_department,
              Colors.orange,
              isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(habitProvider.notifier).deleteHabit(habit.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
} 