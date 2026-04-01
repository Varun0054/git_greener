import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/auth_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/heatmap_screen.dart';
import 'screens/suggestions_screen.dart';
import 'screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return null;

      final token = authState.value;
      final isAuth = token != null && token.isNotEmpty;
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!isAuth && !isGoingToOnboarding) {
        return '/onboarding';
      }
      if (isAuth && isGoingToOnboarding) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/heatmap',
            builder: (context, state) => const HeatmapScreen(),
          ),
          GoRoute(
            path: '/suggestions',
            builder: (context, state) => const SuggestionsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class GitHubGreenerApp extends ConsumerWidget {
  const GitHubGreenerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GitHub Greener',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF2DA44E),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: const Color(0xFF1F2328),
          displayColor: const Color(0xFF1F2328),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DA44E),
          surface: const Color(0xFFFFFFFF),
          primary: const Color(0xFF2DA44E),
        ),
      ),
      routerConfig: router,
    );
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Heatmap'),
          NavigationDestination(icon: Icon(Icons.lightbulb), label: 'Ideas'),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/heatmap')) return 1;
    if (location.startsWith('/suggestions')) return 2;
    return 0; // Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/heatmap');
        break;
      case 2:
        context.go('/suggestions');
        break;
    }
  }
}
