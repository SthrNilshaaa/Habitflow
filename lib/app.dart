import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
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
import 'widgets/liquid_glass_bottom_nav.dart';
import 'models/habit.dart';

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
            backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_active, 
                      size: 48, 
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enable Notifications',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'To get habit reminders and stay on track, please allow notifications.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                        elevation: 8,
                      ),
                      onPressed: () async {
                        await NotificationService.requestNotificationPermission();
                        if (mounted) Navigator.of(ctx).pop();
                      },
                      child: Text(
                        'Allow Notifications', 
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
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
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFE91E63),
          secondary: Color(0xFF9C27B0),
          surface: Color(0xFFFFFFFF),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFF1A1A1A),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        useMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.mandyRed,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE91E63),
          secondary: Color(0xFF9C27B0),
          surface: Color(0xFF1E1E1E),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFFFFFFFF),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
      ),
      routes: {
        '/add-habit': (context) => const AddEditHabitScreen(),
        '/habit-details': (context) {
          final habit = ModalRoute.of(context)!.settings.arguments as Habit;
          return HabitDetailsScreen(habit: habit);
        },
      },
      home: const MainContent(),
    );
  }
}

class MainContent extends ConsumerStatefulWidget {
  const MainContent({super.key});

  @override
  ConsumerState<MainContent> createState() => _MainContentState();
}

class _MainContentState extends ConsumerState<MainContent> {
  int _selectedIndex = 0;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 100), // Add padding for navigation bar
            child: _screens[_selectedIndex],
          ),
        ),
        bottomNavigationBar: LiquidGlassBottomNav(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _navItems,
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
                        colorScheme.primary.withValues(alpha: 0.8),
                        colorScheme.secondary.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: colorScheme.onPrimary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    color: colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
} 