import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import 'dart:ui';

class ListViewScreen extends ConsumerStatefulWidget {
  final void Function(dynamic habit)? onHabitTap;
  const ListViewScreen({super.key, this.onHabitTap});

  @override
  ConsumerState<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends ConsumerState<ListViewScreen> {
  int _selectedFilter = 0;
  String _searchQuery = '';
  String _sortBy = 'name';
  final List<String> _filters = ['All', 'Completed Today', 'Missed', 'Active', 'Favorites'];
  final List<String> _sortOptions = ['Name', 'Date Created', 'Last Completed', 'Streak'];

  List _filterHabits(List habits) {
    List filtered = habits.where((habit) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        final nameMatch = habit.name.toLowerCase().contains(query);
        final descriptionMatch = (habit.description?.toLowerCase().contains(query) ?? false);
        final typeMatch = habit.type.toLowerCase().contains(query);
        
        if (!nameMatch && !descriptionMatch && !typeMatch) {
          return false;
        }
      }

      // Category filter
      switch (_selectedFilter) {
        case 0: // All
          return true;
        case 1: // Completed Today
          final today = DateTime.now();
          return habit.history.any((date) =>
              date.year == today.year &&
              date.month == today.month &&
              date.day == today.day);
        case 2: // Missed
          final today = DateTime.now();
          final lastCompleted = habit.history.isNotEmpty
              ? habit.history.last
              : null;
          return lastCompleted == null ||
              (today.difference(lastCompleted).inDays > 1);
        case 3: // Active
          return habit.isActive && habit.history.isNotEmpty;
        case 4: // Favorites
          return habit.isFavorite;
        default:
          return true;
      }
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'dateCreated':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'lastCompleted':
        filtered.sort((a, b) {
          final aLast = a.history.isNotEmpty ? a.history.last : DateTime(1900);
          final bLast = b.history.isNotEmpty ? b.history.last : DateTime(1900);
          return bLast.compareTo(aLast);
        });
        break;
      case 'streak':
        filtered.sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitProvider);
    final filteredHabits = _filterHabits(habits);
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
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.08),
            ),
          ),
        ),
        Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 45.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // Header with search
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDark 
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search, color: isDark ? Colors.white70 : Colors.black54),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Search habits...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                      onPressed: () => setState(() => _searchQuery = ''),
                                    )
                                  : null,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 16,
                            ),
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                      ],
                    ),
          const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _sortOptions.asMap().entries.map((entry) {
                              final options = ['name', 'dateCreated', 'lastCompleted', 'streak'];
                              return DropdownMenuItem(
                                value: options[entry.key],
                                child: Text(entry.value),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _sortBy = value!),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                            dropdownColor: isDark 
                                ? Colors.grey[900]!.withOpacity(0.95)
                                : Colors.white.withOpacity(0.95),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Icon(
                            Icons.sort,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () => _showSortDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (i) {
                final selected = _selectedFilter == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                          color: selected 
                              ? Colors.blueAccent.withOpacity(0.7) 
                              : (isDark ? Colors.white.withOpacity(0.10) : Colors.white.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            if (selected)
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                          ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _selectedFilter = i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          _filters[i],
                          style: TextStyle(
                                color: selected 
                                    ? Colors.white 
                                    : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
              
              // Results count
              if (filteredHabits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5,left: 12),
                  child: Text(
                    '${filteredHabits.length} habit${filteredHabits.length == 1 ? '' : 's'} found',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              
          filteredHabits.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                            Icon(
                              Icons.search_off, 
                              size: 80, 
                              color: Colors.blueAccent.withOpacity(0.3)
                            ),
                        const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty 
                                  ? 'No habits match your search'
                                  : 'No habits found!',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(
                                  color: isDark ? Colors.white54 : Colors.black45,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    itemCount: filteredHabits.length,
                    //separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) => HabitCard(
                      habit: filteredHabits[i],
                          onTap: () => Navigator.pushNamed(
                            context, 
                            '/habit-details',
                            arguments: filteredHabits[i],
                          ),
                          onComplete: () async {
                            await ref.read(habitProvider.notifier).markCompleted(
                              filteredHabits[i].id, 
                              DateTime.now(),
                            );
                          },
                          onDelete: () => _showDeleteDialog(context, ref, filteredHabits[i]),
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

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sort Habits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sortOptions.asMap().entries.map((entry) {
            final options = ['name', 'dateCreated', 'lastCompleted', 'streak'];
            final isSelected = _sortBy == options[entry.key];
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? Colors.blueAccent : null,
              ),
              title: Text(entry.value),
              onTap: () {
                setState(() => _sortBy = options[entry.key]);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, dynamic habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitProvider.notifier).deleteHabit(habit.id);
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