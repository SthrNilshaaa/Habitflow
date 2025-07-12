import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../services/notification_service.dart';

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
  String _selectedType = '';
  String _selectedFrequency = '';
  String? _selectedReminderTime;
  bool _isReminderOn = false;
  int _targetDays = 30;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.habit.name;
    _descriptionController.text = widget.habit.description ?? '';
    _selectedType = widget.habit.type;
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
    if (widget.habit.isCompletedToday) {
      await ref.read(habitProvider.notifier).markUncompleted(widget.habit.id, DateTime.now());
    } else {
      await ref.read(habitProvider.notifier).markCompleted(widget.habit.id, DateTime.now());
      await NotificationService.showCompletionNotification(widget.habit);
    }
  }

  void _toggleActive() async {
    await ref.read(habitProvider.notifier).toggleHabitActive(widget.habit.id);
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
      type: _selectedType,
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
                  ? Colors.black.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: _isEditing 
                ? TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Habit Name',
                    ),
                  )
                : Text(habit.name),
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            titleSpacing: 16,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.save : Icons.edit),
                onPressed: _isEditing ? _saveChanges : () => setState(() => _isEditing = true),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
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
                _buildCompletionCard(habit),
                const SizedBox(height: 16),
                
                // Statistics Cards
                _buildStatisticsCards(habit),
                const SizedBox(height: 16),
                
                // Progress Chart
                _buildProgressChart(habit),
                const SizedBox(height: 16),
                
                // Habit Details
                _buildHabitDetails(habit),
                const SizedBox(height: 16),
                
                // History
                _buildHistorySection(habit),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionCard(Habit habit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.15),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.1),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      habit.isCompletedToday ? 'Completed! 🎉' : 'Not completed yet',
                      style: TextStyle(
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
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                habit.isCompletedToday ? Colors.green : Colors.blueAccent,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '${habit.history.length}/${habit.targetDays} days completed',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(Habit habit) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Current Streak', '${habit.currentStreak}', Icons.local_fire_department),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Longest Streak', '${habit.longestStreak}', Icons.emoji_events),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('This Week', '${habit.getWeeklyCompletionCount()}', Icons.calendar_today),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(Habit habit) {
    // Create weekly data for the last 4 weeks
    final weeks = List.generate(4, (index) {
      final weekStart = DateTime.now().subtract(Duration(days: (3 - index) * 7));
      return habit.history.where((date) {
        final weekEnd = weekStart.add(const Duration(days: 6));
        return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               date.isBefore(weekEnd.add(const Duration(days: 1)));
      }).length;
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 7,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const weeks = ['4w ago', '3w ago', '2w ago', 'This week'];
                        return Text(
                          weeks[value.toInt()],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(4, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weeks[index].toDouble(),
                        color: Colors.blueAccent,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitDetails(Habit habit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habit Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Type', habit.type),
          _buildDetailRow('Frequency', habit.frequency),
          _buildDetailRow('Status', habit.isActive ? 'Active' : 'Paused'),
          if (habit.description?.isNotEmpty == true)
            _buildDetailRow('Description', habit.description!),
          if (habit.isReminderOn && habit.reminderTime != null)
            _buildDetailRow('Reminder', habit.reminderTime!),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleActive,
                  icon: Icon(habit.isActive ? Icons.pause : Icons.play_arrow),
                  label: Text(habit.isActive ? 'Pause' : 'Activate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: habit.isActive ? Colors.orange : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(Habit habit) {
    final sortedHistory = habit.history.toList()..sort((a, b) => b.compareTo(a));
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Completions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          if (sortedHistory.isEmpty)
            Center(
              child: Text(
                'No completions yet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                ),
              ),
            )
          else
            ...sortedHistory.take(10).map((date) => _buildHistoryItem(date)),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(DateTime date) {
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
            '${date.day}/${date.month}/${date.year}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 