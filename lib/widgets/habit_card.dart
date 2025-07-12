import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../models/habit.dart';
import 'dart:ui';

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
    
    return ZoomTapAnimation(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue[(habit.colorIndex + 1) * 100],
                          child: Icon(
                            _getHabitIcon(habit.type),
                            size: 32, 
                            color: Colors.white
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      habit.name, 
                                      style: GoogleFonts.poppins(
                                        fontSize: 18, 
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (habit.isCompletedToday)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                habit.type, 
                                style: GoogleFonts.poppins(
                                  fontSize: 13, 
                                  color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey,
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
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.emoji_events,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${habit.longestStreak} longest',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: habit.completionRate,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: isDark 
                          ? Colors.grey.withValues(alpha: 0.3)
                          : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        habit.isCompletedToday ? Colors.green : Colors.blue[(habit.colorIndex + 1) * 100] ?? Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${habit.history.length}/${habit.targetDays} completed',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.grey,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!habit.isCompletedToday)
                              IconButton(
                                onPressed: onComplete,
                                icon: const Icon(Icons.check_circle_outline),
                                color: Colors.green,
                                iconSize: 20,
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                            IconButton(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red,
                              iconSize: 20,
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getHabitIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fitness':
        return Icons.fitness_center;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'productivity':
        return Icons.work;
      case 'health':
        return Icons.favorite;
      case 'learning':
        return Icons.school;
      case 'social':
        return Icons.people;
      default:
        return Icons.emoji_events;
    }
  }
} 