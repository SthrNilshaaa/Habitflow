import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/list_view_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/add_edit_habit_screen.dart';
import 'screens/habit_details_screen.dart';
import 'services/notification_service.dart';
import 'providers/settings_provider.dart';
import 'providers/habit_provider.dart';
import 'widgets/liquid_glass_bottom_nav.dart';
import 'models/habit.dart';
import 'dart:async';
import 'screens/splash_screen.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  bool _askedNotification = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeAskNotificationPermission();
  }

  Future<void> _maybeAskNotificationPermission() async {
    if (_askedNotification) return;
    _askedNotification = true;
    if (Platform.isAndroid) {
      // Only ask if not already granted and not previously denied
      final granted = await NotificationService.requestNotificationPermission();
      if (!granted && mounted) {
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_active, size: 48, color: Colors.blueAccent),
                    const SizedBox(height: 16),
                    const Text(
                      'Enable Notifications',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'To get habit reminders and stay on track, please allow notifications.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.withValues(alpha: 0.85),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        elevation: 8,
                      ),
                      onPressed: () async {
                        await NotificationService.requestNotificationPermission();
                        if (mounted && ctx.mounted) Navigator.of(ctx).pop();
                      },
                      child: const Text('Allow Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: FlexThemeData.light(
        scheme: FlexScheme.mandyRed,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1E1E1E),
          primary: Color(0xFFBB86FC),
          secondary: Color(0xFF03DAC6),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/main': (context) => const MainContent(),
        '/add-habit': (context) => const AddEditHabitScreen(),
        '/habit-details': (context) {
          final habit = ModalRoute.of(context)!.settings.arguments as Habit;
          return HabitDetailsScreen(habit: habit);
        },
      },
    );
  }
}

class MainContent extends ConsumerStatefulWidget {
  const MainContent({super.key});

  @override
  ConsumerState<MainContent> createState() => _MainContentState();
}

class _MainContentState extends ConsumerState<MainContent> {
   late PageController _pageController;
   //late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _selectedIndex = 0;
  
  Timer? _missedHabitTimer;
  final List<Widget> _screens = const [
    DashboardScreen(),
    ListViewScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];
  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.home, title: 'Dashboard'),
    BottomNavItem(icon: Icons.list, title: 'List View'),
    BottomNavItem(icon: Icons.insights, title: 'Insights'),
    BottomNavItem(icon: Icons.settings, title: 'Settings'),
  ];

  @override
  void initState() {
    super.initState();
    _startMissedHabitTimer();
    _pageController = PageController(initialPage: _selectedIndex);
    //  _animationController = AnimationController(
    //   duration: const Duration(milliseconds: 300),
    //   vsync: this,
    // );
    // _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    // );
    // _animationController.forward();
  }

  @override
  void dispose() {
    _missedHabitTimer?.cancel();
    _pageController.dispose();
    //_animationController.dispose();
    super.dispose();
  }

  void _startMissedHabitTimer() {
    // Check for missed habits every 5 minutes
    _missedHabitTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        ref.read(habitProvider.notifier).checkMissedHabits();
      }
    });
  }
  void _onPageChanged(int index) {
    if (_selectedIndex != index) {
    setState(() {
      _selectedIndex = index;
    });
    HapticFeedback.selectionClick();
    }
  }

   void _onItemTapped(int index) {
    if (_selectedIndex != index) {
    setState(() {
      _selectedIndex = index;
    });
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
     _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body:Stack(
          children: [
            PageView(
              scrollDirection: Axis.vertical,
              children: _screens,
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: BouncingScrollPhysics(),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              height: 120,
              child: LiquidGlassBottomNav(
          currentIndex: _selectedIndex,
          onTap: (index) => _onItemTapped(index),
          items: _navItems,
        ),
            ),
          
            //position for floating action button
            
          ],
        ),
        
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(

                onPressed: () {
                  Navigator.pushNamed(context, '/add-habit');
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.blueAccent.withValues(alpha: 0.8),
                        Colors.purpleAccent.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation:FloatingActionButtonLocation.endTop
      ),
    );
  }
} 