import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/habit_provider.dart';
import 'dart:ui';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (habits.isEmpty) {
      return Stack(
        children: [
          _buildBackground(isDark),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: Colors.blueAccent.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No data to analyze',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some habits to see your insights',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final stats = _calculateStatistics(habits);
    final weeklyData = _getWeeklyData(habits);
    final categoryData = _getCategoryData(habits);
    final streakData = _getStreakData(habits);

    return Stack(
      children: [
        _buildBackground(isDark),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDark 
                      ? Colors.white.withOpacity(0.08)
                      : Colors.white.withOpacity(0.12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Your Insights',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Key Statistics
              _buildStatisticsGrid(stats, isDark),
              const SizedBox(height: 24),

              // Weekly Progress
              _buildWeeklyProgress(weeklyData, isDark),
              const SizedBox(height: 24),

              // Category Distribution
              _buildCategoryDistribution(categoryData, isDark),
              const SizedBox(height: 24),

              // Streak Analysis
              _buildStreakAnalysis(streakData, isDark),
              const SizedBox(height: 24),

              // Achievement Badges
              _buildAchievements(stats, isDark),
                const SizedBox(height: 24),

              // Top Performing Habits
              _buildTopHabits(habits, isDark),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 70),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(bool isDark) {
    return AnimatedContainer(
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
    );
  }

  Map<String, dynamic> _calculateStatistics(List habits) {
    final totalCompleted = habits.fold<int>(0, (sum, h) => sum + (h.history.length as int));
    final totalHabits = habits.length;
    final completionRate = totalHabits > 0 ? (totalCompleted / (totalHabits * 30) * 100).toInt() : 0;
    final averageStreak = habits.isEmpty ? 0 : habits.fold<int>(0, (sum, h) => sum + (h.currentStreak as int)) ~/ totalHabits;
    final longestStreak = habits.isEmpty ? 0 : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
    final todayCompleted = habits.where((h) {
      final today = DateTime.now();
      return h.history.any((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);
    }).length;

    return {
      'totalCompleted': totalCompleted,
      'totalHabits': totalHabits,
      'completionRate': completionRate,
      'averageStreak': averageStreak,
      'longestStreak': longestStreak,
      'todayCompleted': todayCompleted,
    };
  }

  List<FlSpot> _getWeeklyData(List habits) {
    final now = DateTime.now();
    final weekData = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      int completed = 0;
      for (final habit in habits) {
        if (habit.history.any((h) =>
            h.year == date.year &&
            h.month == date.month &&
            h.day == date.day)) {
          completed++;
        }
      }
      return FlSpot(index.toDouble(), completed.toDouble());
    });
    return weekData;
  }

  List<PieChartSectionData> _getCategoryData(List habits) {
    final categoryCount = <String, int>{};
    for (final habit in habits) {
      categoryCount[habit.type] = (categoryCount[habit.type] ?? 0) + 1;
    }
    
    final colors = [Colors.blue, Colors.green, Colors.purple, Colors.orange, Colors.red];
    return categoryCount.entries.map((entry) {
      final index = categoryCount.keys.toList().indexOf(entry.key);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: colors[index % colors.length],
        title: '${entry.key}\n${entry.value}',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Map<String, dynamic> _getStreakData(List habits) {
    final activeHabits = habits.where((h) => h.history.isNotEmpty).length;
    final perfectStreaks = habits.where((h) => h.currentStreak >= 7).length;
    final totalStreakDays = habits.fold<int>(0, (sum, h) => sum + (h.currentStreak as int));
    
    return {
      'activeHabits': activeHabits,
      'perfectStreaks': perfectStreaks,
      'totalStreakDays': totalStreakDays,
      'averageStreak': habits.isEmpty ? 0 : totalStreakDays ~/ habits.length,
    };
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> stats, bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard('Total Completed', '${stats['totalCompleted']}', Icons.check_circle, Colors.green, isDark),
        _buildStatCard('Completion Rate', '${stats['completionRate']}%', Icons.trending_up, Colors.blue, isDark),
        _buildStatCard('Today Completed', '${stats['todayCompleted']}', Icons.today, Colors.orange, isDark),
        _buildStatCard('Longest Streak', '${stats['longestStreak']}', Icons.local_fire_department, Colors.red, isDark),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(List<FlSpot> weekData, bool isDark) {
    return _buildGlassSection(
      'Weekly Progress',
      Icons.calendar_today,
                SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    return Text(
                      days[value.toInt() % 7],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: weekData,
                isCurved: true,
                color: Colors.blueAccent,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.blueAccent,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blueAccent.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
      isDark,
    );
  }

  Widget _buildCategoryDistribution(List<PieChartSectionData> categoryData, bool isDark) {
    return _buildGlassSection(
      'Habit Categories',
      Icons.pie_chart,
      SizedBox(
        height: 200,
        child: categoryData.isEmpty
            ? Center(
                child: Text(
                  'No category data',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              )
            : PieChart(
                    PieChartData(
                  sections: categoryData,
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                ),
              ),
      ),
      isDark,
    );
  }

  Widget _buildStreakAnalysis(Map<String, dynamic> streakData, bool isDark) {
    return _buildGlassSection(
      'Streak Analysis',
      Icons.local_fire_department,
      Column(
        children: [
          _buildStreakItem('Active Habits', '${streakData['activeHabits']}', Icons.play_circle, Colors.green, isDark),
          const SizedBox(height: 12),
          _buildStreakItem('Perfect Streaks', '${streakData['perfectStreaks']}', Icons.star, Colors.orange, isDark),
          const SizedBox(height: 12),
          _buildStreakItem('Total Streak Days', '${streakData['totalStreakDays']}', Icons.trending_up, Colors.blue, isDark),
        ],
      ),
      isDark,
    );
  }

  Widget _buildStreakItem(String label, String value, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(Map<String, dynamic> stats, bool isDark) {
    final achievements = <Map<String, dynamic>>[];
    
    if (stats['totalCompleted'] >= 10) {
      achievements.add({'name': 'Getting Started', 'icon': Icons.emoji_events, 'color': Colors.amber});
    }
    if (stats['completionRate'] >= 80) {
      achievements.add({'name': 'Consistency Master', 'icon': Icons.psychology, 'color': Colors.purple});
    }
    if (stats['longestStreak'] >= 7) {
      achievements.add({'name': 'Streak Champion', 'icon': Icons.local_fire_department, 'color': Colors.red});
    }
    if (stats['totalHabits'] >= 5) {
      achievements.add({'name': 'Habit Collector', 'icon': Icons.collections, 'color': Colors.blue});
    }

    return _buildGlassSection(
      'Achievements',
      Icons.emoji_events,
      achievements.isEmpty
          ? Center(
              child: Text(
                'Complete more habits to unlock achievements!',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return Container(
                  decoration: BoxDecoration(
                    color: achievement['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: achievement['color'].withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        achievement['icon'],
                        color: achievement['color'],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
      isDark,
    );
  }

  Widget _buildTopHabits(List habits, bool isDark) {
    final sortedHabits = List.from(habits)
      ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
    
    final topHabits = sortedHabits.take(3).toList();

    return _buildGlassSection(
      'Top Performing Habits',
      Icons.leaderboard,
      topHabits.isEmpty
          ? Center(
              child: Text(
                'No habits to display',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            )
          : Column(
              children: topHabits.asMap().entries.map((entry) {
                final index = entry.key;
                final habit = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getHabitColor(habit.type),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              '${habit.currentStreak} day streak',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
      isDark,
    );
  }

  Color _getHabitColor(String type) {
    switch (type.toLowerCase()) {
      case 'fitness':
        return Colors.green;
      case 'mindfulness':
        return Colors.purple;
      case 'productivity':
        return Colors.blue;
      case 'health':
        return Colors.red;
      case 'learning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildGlassSection(String title, IconData icon, Widget child, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
      decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.08),
                blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ],
    );
  }
} 