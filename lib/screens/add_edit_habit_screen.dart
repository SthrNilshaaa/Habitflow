import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class AddEditHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit;
  
  const AddEditHabitScreen({super.key, this.habit});

  @override
  ConsumerState<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends ConsumerState<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;
  String _selectedType = 'Fitness';
  String _selectedFrequency = 'daily';
  String? _selectedReminderTime;
  bool _isReminderOn = false;
  int _targetDays = 30;

  final List<IconData> _habitIcons = [
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

  final List<Color> _habitColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  final List<String> _habitTypes = [
    'Fitness',
    'Mindfulness',
    'Learning',
    'Productivity',
    'Health',
    'Social',
    'Creative',
    'Finance',
  ];

  final List<String> _frequencies = [
    'daily',
    'weekly',
    'custom',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description ?? '';
      _selectedIconIndex = widget.habit!.iconIndex;
      _selectedColorIndex = widget.habit!.colorIndex;
      _selectedType = widget.habit!.type;
      _selectedFrequency = widget.habit!.frequency;
      _selectedReminderTime = widget.habit!.reminderTime;
      _isReminderOn = widget.habit!.isReminderOn;
      _targetDays = widget.habit!.targetDays;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            title: Text(
              widget.habit != null ? 'Edit Habit' : 'Add Habit',
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
          ),
          body: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: colorScheme.surface.withValues(alpha: isDark ? 0.1 : 0.15),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    color: colorScheme.surface.withValues(alpha: isDark ? 0.08 : 0.18),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.10),
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
                        _buildIconColorSelector(isDark, colorScheme),
                        const SizedBox(height: 24),

                        // Basic Information
                        _buildBasicInfoSection(isDark, colorScheme),
                        const SizedBox(height: 24),

                        // Habit Type and Frequency
                        _buildTypeFrequencySection(isDark, colorScheme),
                        const SizedBox(height: 24),

                        // Reminder Settings
                        _buildReminderSection(isDark, colorScheme),
                        const SizedBox(height: 24),

                        // Advanced Settings
                        _buildAdvancedSettingsSection(isDark, colorScheme),
                        const SizedBox(height: 32),

                        // Save Button
                        _buildSaveButton(isDark, colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconColorSelector(bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Icon & Color',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
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
                  color: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Icon',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
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
                                    ? _habitColors[_selectedColorIndex].withValues(alpha: 0.2)
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
                  color: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Color',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildBasicInfoSection(bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Habit Name',
            labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            fillColor: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
            filled: true,
          ),
          style: TextStyle(color: colorScheme.onSurface),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a habit name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description (Optional)',
            labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
            fillColor: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
            filled: true,
          ),
          style: TextStyle(color: colorScheme.onSurface),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildTypeFrequencySection(bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type & Frequency',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Habit Type',
                  labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  fillColor: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
                  filled: true,
                ),
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface),
                items: _habitTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                  fillColor: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
                  filled: true,
                ),
                dropdownColor: colorScheme.surface,
                style: TextStyle(color: colorScheme.onSurface),
                items: _frequencies.map((freq) {
                  return DropdownMenuItem(
                    value: freq,
                    child: Text(freq),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFrequency = value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReminderSection(bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Enable Reminders',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Switch(
                    value: _isReminderOn,
                    onChanged: (value) => setState(() => _isReminderOn = value),
                    activeColor: colorScheme.primary,
                  ),
                ],
              ),
              if (_isReminderOn) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedReminderTime != null
                          ? TimeOfDay.fromDateTime(DateTime.parse('2024-01-01 ${_selectedReminderTime!}'))
                          : const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (time != null) {
                      setState(() {
                        _selectedReminderTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _selectedReminderTime ?? 'Select Time',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _selectedReminderTime != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettingsSection(bool isDark, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface.withValues(alpha: isDark ? 0.05 : 0.1),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.track_changes,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Target Days',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    '$_targetDays days',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: _targetDays.toDouble(),
                min: 7,
                max: 365,
                divisions: 358,
                activeColor: colorScheme.primary,
                inactiveColor: colorScheme.onSurface.withValues(alpha: 0.2),
                onChanged: (value) => setState(() => _targetDays = value.round()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark, ColorScheme colorScheme) {
    return ElevatedButton(
      onPressed: _saveHabit,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      child: Text(
        widget.habit != null ? 'Update Habit' : 'Create Habit',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }

  void _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: widget.habit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        iconIndex: _selectedIconIndex,
        colorIndex: _selectedColorIndex,
        frequency: _selectedFrequency,
        reminderTime: _selectedReminderTime,
        isReminderOn: _isReminderOn,
        type: _selectedType,
        createdAt: widget.habit?.createdAt ?? DateTime.now(),
        history: widget.habit?.history ?? [],
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        targetDays: _targetDays,
        isActive: widget.habit?.isActive ?? true,
      );

      if (widget.habit != null) {
        await ref.read(habitProvider.notifier).updateHabit(habit);
      } else {
        await ref.read(habitProvider.notifier).addHabit(habit);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
} 