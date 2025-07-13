import 'package:flutter/material.dart';
import 'dart:ui';

class LiquidGlassBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;

  const LiquidGlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<LiquidGlassBottomNav> createState() => _LiquidGlassBottomNavState();
}

class _LiquidGlassBottomNavState extends State<LiquidGlassBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onItemTap(int index) {
    final int currentIndex = widget.currentIndex;
    final int steps = (index - currentIndex).abs();
    
    if (steps > 1) {
      // Show progress animation for multi-step navigation
      _progressController.forward().then((_) {
        _progressController.reset();
        widget.onTap(index);
      });
    } else {
      // Normal single-step navigation
      _animationController.forward().then((_) {
        _animationController.reverse();
        widget.onTap(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                 BoxShadow(
                   color: Colors.black.withValues(alpha: 0.1),
                   blurRadius: 20,
                   offset: const Offset(0, 10),
                 ),
               ],
            ),
            child: Stack(
              children: [
                // Progress indicator for multi-step navigation
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blueAccent.withValues(alpha: 0.8),
                              Colors.purpleAccent.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent.withValues(alpha: 0.9),
                                  Colors.purpleAccent.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Navigation items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(widget.items.length, (index) {
                    final isSelected = widget.currentIndex == index;
                    return Expanded(
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isSelected ? _scaleAnimation.value : 1.0,
                            child: GestureDetector(
                              onTap: () => _onItemTap(index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: isSelected
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.blueAccent.withValues(alpha: 0.8),
                                            Colors.purpleAccent.withValues(alpha: 0.6),
                                          ],
                                        )
                                      : null,
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.blueAccent.withValues(alpha: 0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        child: Icon(
                                          widget.items[index].icon,
                                          color: isSelected
                                              ?Colors.white.withValues(alpha: 0.9)
                                              : isDark?Colors.white.withValues(alpha: 0.7):Colors.black.withValues(alpha: 0.7),
                                          size: isSelected ? 28 : 24,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 200),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white.withValues(alpha: 0.9)
                                              : isDark?Colors.white.withValues(alpha: 0.7):Colors.black.withValues(alpha: 0.7),
                                          fontSize: isSelected ? 12 : 10,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        child: Text(
                                          widget.items[index].title,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String title;

  const BottomNavItem({
    required this.icon,
    required this.title,
  });
} 