import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings ⚙️')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF636C76))),
          const Divider(),
          ListTile(
            title: const Text('GitHub Token'),
            subtitle: const Text('Connected ✅'),
            trailing: TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('AI Suggestions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF636C76))),
          const Divider(),
          const OpenRouterKeyInput(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              '🔒 Privacy: Only repo names, languages, and activity counts are sent to the AI. Your code is never shared.',
              style: TextStyle(fontSize: 12, color: Color(0xFF636C76)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF636C76))),
          const Divider(),
          const ListTile(
            title: Text('Version 1.0.0'),
            subtitle: Text('Made with 🟩 by GitHub Greener'),
          ),
        ],
      ),
    );
  }
}

class OpenRouterKeyInput extends ConsumerStatefulWidget {
  const OpenRouterKeyInput({super.key});

  @override
  ConsumerState<OpenRouterKeyInput> createState() => _OpenRouterKeyInputState();
}

class _OpenRouterKeyInputState extends ConsumerState<OpenRouterKeyInput> {
  final _controller = TextEditingController();
  bool _obscureText = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await ref.read(authProvider.notifier).getOpenRouterKey();
    if (key != null) {
      _controller.text = key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('OpenRouter API Key'),
      subtitle: TextField(
        controller: _controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: 'Enter API Key',
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
      ),
      trailing: _isSaving 
          ? const CircularProgressIndicator()
          : TextButton(
              onPressed: () async {
                setState(() => _isSaving = true);
                await ref.read(authProvider.notifier).setOpenRouterKey(_controller.text);
                ref.invalidate(openRouterKeyProvider);
                if (!context.mounted) return;
                setState(() => _isSaving = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OpenRouter Key saved!')),
                );
              },
              child: const Text('Save'),
            ),
    );
  }
}
