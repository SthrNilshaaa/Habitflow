import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../models/habit.dart';

class ListViewScreen extends ConsumerStatefulWidget {
  const ListViewScreen({super.key});

  @override
  ConsumerState<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends ConsumerState<ListViewScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String _sortBy = 'Name';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Completed Today', 'Missed', 'Active', 'Favorites'];
  final List<String> _sortOptions = ['Name', 'Date Created', 'Last Completed', 'Streak', 'Type'];

  List<Habit> _filterAndSortHabits(List<Habit> habits) {
    List<Habit> filtered = habits.where((habit) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!habit.name.toLowerCase().contains(query) &&
            !(habit.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Category filter
      switch (_selectedFilter) {
        case 'All':
          return true;
        case 'Completed Today':
          return habit.isCompletedToday;
        case 'Missed':
          final today = DateTime.now();
          final lastCompleted = habit.history.isNotEmpty ? habit.history.last : null;
          return lastCompleted == null ||
              (today.difference(lastCompleted).inDays > 1);
        case 'Active':
          return habit.isActive;
        case 'Favorites':
          return habit.isFavorite;
        default:
          return true;
      }
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'Name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Date Created':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Last Completed':
        filtered.sort((a, b) {
          final aLast = a.history.isNotEmpty ? a.history.last : DateTime(1900);
          final bLast = b.history.isNotEmpty ? b.history.last : DateTime(1900);
          return bLast.compareTo(aLast);
        });
        break;
      case 'Streak':
        filtered.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
        break;
      case 'Type':
        filtered.sort((a, b) => a.type.compareTo(b.type));
        break;
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);
    final filteredHabits = _filterAndSortHabits(habits);
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
              'All Habits',
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
          body: Column(
            children: [
              // Search and Filter Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorScheme.surface.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search habits...',
                          prefixIcon: Icon(
                            Icons.search,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Filter and Sort Row
                    Row(
                      children: [
                        // Filter Dropdown
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: colorScheme.surface.withValues(alpha: 0.15),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFilter,
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                items: _filters.map((filter) {
                                  return DropdownMenuItem(
                                    value: filter,
                                    child: Text(
                                      filter,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedFilter = value);
                                  }
                                },
                                dropdownColor: colorScheme.surface.withValues(alpha: 0.95),
                                icon: Icon(
                                  Icons.filter_list,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Sort Dropdown
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: colorScheme.surface.withValues(alpha: 0.15),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _sortBy,
                                isExpanded: true,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                items: _sortOptions.map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _sortBy = value);
                                  }
                                },
                                dropdownColor: colorScheme.surface.withValues(alpha: 0.95),
                                icon: Icon(
                                  Icons.sort,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Results Count
                    if (filteredHabits.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${filteredHabits.length} habit${filteredHabits.length == 1 ? '' : 's'} found',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Habits List
              Expanded(
                child: filteredHabits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty ? Icons.search_off : Icons.list_alt,
                              size: 80,
                              color: colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'No habits match your search'
                                  : habits.isEmpty 
                                      ? 'No habits yet!'
                                      : 'No habits match the filter',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'Try adjusting your search terms'
                                  : habits.isEmpty
                                      ? 'Create your first habit to get started'
                                      : 'Try changing your filter or search',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredHabits.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];
                          return HabitCard(
                            habit: habit,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/habit-details',
                              arguments: habit,
                            ),
                            onComplete: () async {
                              await ref.read(habitProvider.notifier).markCompleted(
                                habit.id,
                                DateTime.now(),
                              );
                            },
                            onDelete: () => _showDeleteDialog(context, ref, habit),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Habit habit) {
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