import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContributeSuccessDialog extends StatefulWidget {
  final String repoName;
  final String? commitUrl;
  final VoidCallback onDone;

  const ContributeSuccessDialog({
    super.key,
    required this.repoName,
    required this.onDone,
    this.commitUrl,
  });

  @override
  State<ContributeSuccessDialog> createState() => _ContributeSuccessDialogState();
}

class _ContributeSuccessDialogState extends State<ContributeSuccessDialog>
    with TickerProviderStateMixin {
  late final List<AnimationController> _squareControllers;
  late final List<Animation<double>> _squareAnimations;

  @override
  void initState() {
    super.initState();
    _squareControllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );
    _squareAnimations = _squareControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeOutBack);
    }).toList();

    // Stagger: 0ms, 150ms, 300ms
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _squareControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _squareControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _openCommit() async {
    final url = widget.commitUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Green top accent bar
          Container(
            height: 5,
            width: double.infinity,
            color: const Color(0xFF2DA44E),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated green squares
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ScaleTransition(
                        scale: _squareAnimations[i],
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2DA44E),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  'Contribution Made! 🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2328),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Body text
                Text.rich(
                  TextSpan(
                    text: 'Successfully committed to ',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF636C76)),
                    children: [
                      TextSpan(
                        text: "'${widget.repoName}'",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2DA44E),
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your GitHub graph just got\na little greener today!',
                  style: TextStyle(fontSize: 14, color: Color(0xFF636C76), height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    if (widget.commitUrl != null) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openCommit,
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: const Text('View Commit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2DA44E),
                            side: const BorderSide(color: Color(0xFF2DA44E)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: widget.onDone,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2DA44E),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
