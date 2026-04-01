import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/heatmap_stats.dart';
import '../providers/auth_provider.dart';
import '../services/nemotron_service.dart';

class AiSummaryCard extends ConsumerStatefulWidget {
  final HeatmapStats stats;

  const AiSummaryCard({super.key, required this.stats});

  @override
  ConsumerState<AiSummaryCard> createState() => _AiSummaryCardState();
}

class _AiSummaryCardState extends ConsumerState<AiSummaryCard> {
  String? _summary;
  bool _isLoading = false;
  String? _error;

  Future<void> _generateSummary() async {
    final key = await ref.read(openRouterKeyProvider.future);
    if (key == null || key.isEmpty) {
      setState(() => _error = 'Add OpenRouter key in Settings for AI insights');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await NemotronService().getHeatmapSummary(
        stats: widget.stats,
        openRouterKey: key,
      );
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEDF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🤖 AI Activity Summary', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2328))),
              const Spacer(),
              if (_summary != null)
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _generateSummary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_summary == null && !_isLoading)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate AI Insights'),
                onPressed: _generateSummary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DA44E),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF2DA44E)),
                    SizedBox(height: 8),
                    Text('Analyzing your patterns with Nemotron...'),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          if (_summary != null && !_isLoading)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                _summary!,
                style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF1F2328)),
              ),
            ),
        ],
      ),
    );
  }
}
