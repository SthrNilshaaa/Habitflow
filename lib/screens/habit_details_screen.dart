import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class HabitDetailsScreen extends ConsumerStatefulWidget {
  final Habit habit;
  
  const HabitDetailsScreen({super.key, required this.habit});

  @override
  ConsumerState<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends ConsumerState<HabitDetailsScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedFrequency = 'daily';
  String? _selectedReminderTime;
  bool _isReminderOn = false;
  int _targetDays = 30;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.habit.name;
    _descriptionController.text = widget.habit.description ?? '';
    _selectedFrequency = widget.habit.frequency;
    _selectedReminderTime = widget.habit.reminderTime;
    _isReminderOn = widget.habit.isReminderOn;
    _targetDays = widget.habit.targetDays;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleCompletion() async {
    final habit = ref.read(habitProvider).firstWhere((h) => h.id == widget.habit.id);
    if (habit.isCompletedToday) {
      await ref.read(habitProvider.notifier).markUncompleted(habit.id, DateTime.now());
    } else {
      await ref.read(habitProvider.notifier).markCompleted(habit.id, DateTime.now());
    }
  }

  void _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${widget.habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(habitProvider.notifier).deleteHabit(widget.habit.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  void _saveChanges() async {
    final updatedHabit = Habit(
      id: widget.habit.id,
      name: _nameController.text,
      iconIndex: widget.habit.iconIndex,
      colorIndex: widget.habit.colorIndex,
      frequency: _selectedFrequency,
      reminderTime: _selectedReminderTime,
      isReminderOn: _isReminderOn,
      type: widget.habit.type,
      createdAt: widget.habit.createdAt,
      history: widget.habit.history,
      description: _descriptionController.text,
      targetDays: _targetDays,
      isActive: widget.habit.isActive,
    );

    await ref.read(habitProvider.notifier).updateHabit(updatedHabit);
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habit = ref.watch(habitProvider).firstWhere((h) => h.id == widget.habit.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

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
            title: _isEditing 
                ? TextField(
                    controller: _nameController,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Habit Name',
                      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  )
                : Text(
                    habit.name,
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
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: colorScheme.onSurface,
                ),
                onPressed: _isEditing ? _saveChanges : () => setState(() => _isEditing = true),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: colorScheme.error,
                ),
                onPressed: _deleteHabit,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion Card
                _buildCompletionCard(habit, isDark, colorScheme),
                const SizedBox(height: 16),
                
                // Statistics Cards
                _buildStatisticsCards(habit, isDark, colorScheme),
                const SizedBox(height: 16),
                
                // Progress Chart
                _buildProgressChart(habit, isDark, colorScheme),
                const SizedBox(height: 16),
                
                // Habit Details
                _buildHabitDetails(habit, isDark, colorScheme),
                const SizedBox(height: 16),
                
                // History
                _buildHistorySection(habit, isDark, colorScheme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard(Habit habit, bool isDark, ColorScheme colorScheme) {
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Progress',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      habit.isCompletedToday ? 'Completed! 🎉' : 'Not completed yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: habit.isCompletedToday ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: habit.isCompletedToday,
                  onChanged: (_) => _toggleCompletion(),
                  activeColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: habit.completionRate,
              backgroundColor: colorScheme.onSurface.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                habit.isCompletedToday ? Colors.green : colorScheme.primary,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${(habit.completionRate * 100).toInt()}% Complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(Habit habit, bool isDark, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current Streak',
            '${habit.currentStreak}',
            Icons.local_fire_department,
            Colors.orange,
            isDark,
            colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Longest Streak',
            '${habit.longestStreak}',
            Icons.emoji_events,
            Colors.amber,
            isDark,
            colorScheme,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Days',
            '${habit.history.length}',
            Icons.calendar_today,
            colorScheme.primary,
            isDark,
            colorScheme,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface.withValues(alpha: 0.15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
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
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(Habit habit, bool isDark, ColorScheme colorScheme) {
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
            'Progress Chart',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: _buildWeeklyChart(habit, isDark, colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(Habit habit, bool isDark, ColorScheme colorScheme) {
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return habit.history.any((h) =>
          h.year == date.year &&
          h.month == date.month &&
          h.day == date.day);
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekData.asMap().entries.map((entry) {
        final index = entry.key;
        final completed = entry.value;
        final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

        return Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: completed ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  dayNames[index],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: completed ? colorScheme.onPrimary : colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${now.subtract(Duration(days: 6 - index)).day}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildHabitDetails(Habit habit, bool isDark, ColorScheme colorScheme) {
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
            'Habit Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Type', habit.type, Icons.category, isDark, colorScheme),
          _buildDetailRow('Frequency', habit.frequency, Icons.repeat, isDark, colorScheme),
          _buildDetailRow('Target Days', '${habit.targetDays} days', Icons.track_changes, isDark, colorScheme),
          if (habit.description != null)
            _buildDetailRow('Description', habit.description!, Icons.description, isDark, colorScheme),
          _buildDetailRow('Created', _formatDate(habit.createdAt), Icons.calendar_today, isDark, colorScheme),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, bool isDark, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(Habit habit, bool isDark, ColorScheme colorScheme) {
    final recentHistory = habit.history.take(10).toList().reversed.toList();

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
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (recentHistory.isEmpty)
            Center(
              child: Text(
                'No activity yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            Column(
              children: recentHistory.map((date) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(date),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 