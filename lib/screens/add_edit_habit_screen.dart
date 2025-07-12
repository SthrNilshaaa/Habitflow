import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import 'package:uuid/uuid.dart';

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit; // For editing existing habits
  const AddEditHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Fitness';
  String _selectedFrequency = 'Daily';
  bool _enableReminder = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  int _targetDays = 30;
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  bool _isFavorite = false;
  bool _showAdvancedSettings = false;

  final List<String> _habitTypes = [
    'Fitness', 'Mindfulness', 'Productivity', 'Health', 'Learning', 'Social', 'Creative'
  ];
  
  final List<String> _frequencies = [
    'Daily', 'Weekly', 'Monthly', 'Custom'
  ];

  final List<IconData> _habitIcons = [
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.work,
    Icons.favorite,
    Icons.school,
    Icons.people,
    Icons.brush,
    Icons.book,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.psychology,
    Icons.computer,
  ];

  final List<Color> _habitColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      // Editing existing habit
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description ?? '';
      _selectedType = widget.habit!.type;
      _selectedFrequency = widget.habit!.frequency;
      _enableReminder = widget.habit!.isReminderOn;
      _targetDays = widget.habit!.targetDays;
      _selectedIconIndex = widget.habit!.iconIndex;
      _selectedColorIndex = widget.habit!.colorIndex;
      _isFavorite = widget.habit!.isFavorite;
      if (widget.habit!.reminderTime != null) {
        final timeParts = widget.habit!.reminderTime!.split(' ');
        final timeComponents = timeParts[0].split(':');
        final hour = int.parse(timeComponents[0]);
        final minute = int.parse(timeComponents[1]);
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).brightness == Brightness.dark
                ? const ColorScheme.dark(primary: Colors.blueAccent)
                : const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: widget.habit?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        iconIndex: _selectedIconIndex,
        colorIndex: _selectedColorIndex,
        frequency: _selectedFrequency,
        reminderTime: _enableReminder 
            ? '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}'
            : null,
        isReminderOn: _enableReminder,
        type: _selectedType,
        createdAt: widget.habit?.createdAt ?? DateTime.now(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        targetDays: _targetDays,
        isFavorite: _isFavorite,
      );

      if (widget.habit != null) {
        await ref.read(habitProvider.notifier).updateHabit(habit);
      } else {
        await ref.read(habitProvider.notifier).addHabit(habit);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.habit != null 
                ? 'Habit "${habit.name}" updated successfully!'
                : 'Habit "${habit.name}" added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  : Colors.white.withValues(alpha: 0.05)
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              widget.habit != null ? 'Edit Habit' : 'Add New Habit',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
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
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              if (widget.habit != null)
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () => _showDeleteDialog(context),
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: isDark 
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Habit Icon and Color Selection
                      _buildIconColorSelector(isDark),
                      const SizedBox(height: 24),

                      // Basic Information
                      _buildBasicInfoSection(isDark),
                      const SizedBox(height: 24),

                      // Habit Type and Frequency
                      _buildTypeFrequencySection(isDark),
                      const SizedBox(height: 24),

                      // Reminder Settings
                      _buildReminderSection(isDark),
                      const SizedBox(height: 24),

                      // Advanced Settings
                      _buildAdvancedSettingsSection(isDark),
                      const SizedBox(height: 32),

                      // Save Button
                      _buildSaveButton(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconColorSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Icon & Color',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Icon Selector
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Icon',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      _habitIcons[_selectedIconIndex],
                      color: _habitColors[_selectedColorIndex],
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _habitIcons.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIconIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _selectedIconIndex == index
                                    ? _habitColors[_selectedColorIndex].withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedIconIndex == index
                                      ? _habitColors[_selectedColorIndex]
                                      : Colors.transparent,
                                ),
                              ),
                              child: Icon(
                                _habitIcons[index],
                                color: _habitColors[_selectedColorIndex],
                                size: 20,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Color Selector
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Color',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _habitColors[_selectedColorIndex],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _habitColors.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => setState(() => _selectedColorIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _habitColors[index],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedColorIndex == index
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBasicInfoSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a habit name';
            }
            if (value.trim().length < 2) {
              return 'Habit name must be at least 2 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Habit Name',
            hintText: 'e.g., Morning Exercise',
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            hintText: 'Describe your habit...',
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                title: Text(
                  'Mark as Favorite',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Pin this habit to the top',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                value: _isFavorite,
                onChanged: (value) => setState(() => _isFavorite = value),
                activeColor: Colors.amber,
                inactiveThumbColor: isDark ? Colors.grey[600] : Colors.grey[300],
                inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeFrequencySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Type & Frequency',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
                items: _habitTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                dropdownColor: isDark ? Colors.grey[900]!.withOpacity(0.95) : Colors.white.withOpacity(0.95),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  filled: true,
                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                ),
                items: _frequencies.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedFrequency = value!),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                dropdownColor: isDark ? Colors.grey[900]!.withOpacity(0.95) : Colors.white.withOpacity(0.95),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            'Enable Reminders',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Get notified to complete this habit',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
            ),
          ),
          value: _enableReminder,
          onChanged: (value) => setState(() => _enableReminder = value),
          activeColor: Colors.blueAccent,
          inactiveThumbColor: isDark ? Colors.grey[600] : Colors.grey[300],
          inactiveTrackColor: isDark ? Colors.grey[800] : Colors.grey[400],
        ),
        if (_enableReminder) ...[
          const SizedBox(height: 16),
          InkWell(
            onTap: _selectTime,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.blueAccent,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminder Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        Text(
                          '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdvancedSettingsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showAdvancedSettings = !_showAdvancedSettings),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Colors.blueAccent,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Advanced Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  _showAdvancedSettings ? Icons.expand_less : Icons.expand_more,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
        if (_showAdvancedSettings) ...[
          const SizedBox(height: 16),
          Text(
            'Target Days',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _targetDays.toDouble(),
                  min: 7,
                  max: 365,
                  divisions: 358,
                  activeColor: Colors.blueAccent,
                  inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
                  onChanged: (value) => setState(() => _targetDays = value.round()),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_targetDays days',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return ElevatedButton(
      onPressed: _saveHabit,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      child: Text(
        widget.habit != null ? 'Update Habit' : 'Create Habit',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${widget.habit!.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitProvider.notifier).deleteHabit(widget.habit!.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 