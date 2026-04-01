import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/suggestion.dart';
import '../services/contribute_service.dart';
import '../providers/auth_provider.dart';
import '../providers/contributions_provider.dart';
import '../providers/suggestions_provider.dart';
import 'contribute_success_dialog.dart';

class SuggestionCard extends ConsumerStatefulWidget {
  final Suggestion suggestion;

  const SuggestionCard({super.key, required this.suggestion});

  @override
  ConsumerState<SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends ConsumerState<SuggestionCard> {
  bool _isLoading = false;

  Future<void> _handleContribute() async {
    setState(() => _isLoading = true);

    final pat = ref.read(authProvider).value;
    if (pat == null) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await ContributeService().contribute(
      owner: widget.suggestion.owner,
      repoName: widget.suggestion.repoName,
      pat: pat,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      // Show celebratory dialog — refresh happens after Done is tapped
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ContributeSuccessDialog(
          repoName: widget.suggestion.repoName,
          commitUrl: result.commitUrl,
          onDone: () {
            Navigator.pop(context);
            ref.invalidate(contributionsProvider);
            ref.invalidate(suggestionsProvider);
          },
        ),
      );
    } else {
      String errorMsg = 'Something went wrong. Try again.';
      if (result.error?.contains('401') == true) { errorMsg = 'Invalid token — check your PAT in Settings'; }
      else if (result.error?.contains('403') == true) { errorMsg = 'No write access to this repo'; }
      else if (result.error?.contains('404') == true) { errorMsg = 'Repo not found — may be deleted or renamed'; }
      else if (result.error?.contains('409') == true) { errorMsg = 'Conflict — try again in a moment'; }
      else if (result.error?.toLowerCase().contains('socket') == true) { errorMsg = 'No internet connection'; }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _colorForType(widget.suggestion.type);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: typeColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder, size: 16, color: Color(0xFF636C76)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.suggestion.repoName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2328)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.suggestion.reason,
                  style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.suggestion.message,
            style: const TextStyle(color: Color(0xFF1F2328), height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.suggestion.message));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy ⎘'),
              ),
              const SizedBox(width: 8),
              _buildContributeButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContributeButton() {
    if (_isLoading) {
      return const OutlinedButton(
        onPressed: null,
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return OutlinedButton(
      onPressed: _handleContribute,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2DA44E),
        side: const BorderSide(color: Color(0xFF2DA44E)),
      ),
      child: const Text('Contribute 🟩'),
    );
  }

  Color _colorForType(SuggestionType type) {
    return switch (type) {
      SuggestionType.dailyCommit      => const Color(0xFF2DA44E),
      SuggestionType.addReadme        => const Color(0xFF0969DA),
      SuggestionType.fixOpenIssue     => const Color(0xFFBF8700),
      SuggestionType.reviveOldRepo    => const Color(0xFFCF222E),
      SuggestionType.pushLocalChanges => const Color(0xFF8250DF),
      SuggestionType.updateDescription=> const Color(0xFF1B7FC4),
      SuggestionType.addTests         => const Color(0xFFE16F24),
      _                               => const Color(0xFF636C76),
    };
  }
}
