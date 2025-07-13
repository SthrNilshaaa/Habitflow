import 'package:flutter/material.dart';
import 'dart:math';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

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

class _LiquidGlassBottomNavState extends State<LiquidGlassBottomNav> with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;
  late List<AnimationController> _itemControllers;
  late List<Animation<double>> _itemAnimations;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );
    _entranceController.forward();

    _itemControllers = List.generate(widget.items.length, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });
    _itemAnimations = _itemControllers.map((c) => CurvedAnimation(parent: c, curve: Curves.easeOutBack)).toList();
    // Animate the selected item in
    _itemControllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(covariant LiquidGlassBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _itemControllers[oldWidget.currentIndex].reverse();
      _itemControllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lightAngle = (DateTime.now().millisecondsSinceEpoch % 4000) / 4000 * 2 * pi;
    final settings = LiquidGlassSettings(
      thickness: 15,
      lightAngle: lightAngle,
      lightIntensity: 1,
      ambientStrength: 0.5,
      blend: 50,
      chromaticAberration: 0.5,
      blur: 20,
      glassColor: isDark
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.black.withValues(alpha: 0.10),
      refractiveIndex: 1.3,
    );
    return FadeTransition(
      opacity: _entranceAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_entranceAnimation),
        child: Container(
          margin: const EdgeInsets.all(16.0),
          height: 80,
          child: LiquidGlassLayer(
            settings: settings,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(widget.items.length, (index) {
                  final isSelected = widget.currentIndex == index;
                  return Expanded(
                    child: _AnimatedNavItem(
                      item: widget.items[index],
                      isSelected: isSelected,
                      onTap: () {
                        widget.onTap(index);
                      },
                      animation: _itemAnimations[index],
                      isDark: isDark,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedNavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double> animation;
  final bool isDark;

  const _AnimatedNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.animation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final scale = isSelected ? 1.1 * animation.value : 1.0;
          final color = isSelected
              ? Colors.white.withValues(alpha: (0.9 * animation.value).clamp(0, 1))
              : isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.7);
          return Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blueAccent.withValues(alpha: (0.8 * animation.value).clamp(0, 1)),
                          Colors.purpleAccent.withValues(alpha: (0.6 * animation.value).clamp(0, 1)),
                        ],
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: (0.3 * animation.value).clamp(0, 1)),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    color: color,
                    size: isSelected ? 28 : 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: color,
                      fontSize: isSelected ? 12 : 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
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