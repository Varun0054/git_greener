import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/contributions_provider.dart';
import '../widgets/contribution_graph.dart';
import '../widgets/streak_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: contributionsAsync.when(
          data: (data) => Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(data.profile.avatarUrl),
                radius: 16,
              ),
              const SizedBox(width: 8),
              Text('@${data.profile.login}'),
            ],
          ),
          loading: () => const Text('Loading...'),
          error: (err, st) => const Text('GitHub Greener'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: contributionsAsync.when(
        data: (data) {
          return RefreshIndicator(
            onRefresh: () async {
               ref.invalidate(contributionsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 24)),
                    Text(
                      '${data.currentStreak} day streak',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: StreakCard(title: 'Current streak', value: '${data.currentStreak}')),
                    const SizedBox(width: 8),
                    Expanded(child: StreakCard(title: 'Longest streak', value: '${data.longestStreak}')),
                    const SizedBox(width: 8),
                    Expanded(child: StreakCard(title: 'Total contribs', value: '${data.totalContributions}')),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Contribution Graph',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ContributionGraph(days: data.days),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              ElevatedButton(
                onPressed: () => ref.invalidate(contributionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
