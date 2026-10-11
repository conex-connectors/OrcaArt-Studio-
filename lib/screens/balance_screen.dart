import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class _Row {
  final String label;
  final String key;
  final IconData icon;
  const _Row(this.label, this.key, this.icon);
}

const _rows = [
  _Row('Videos remaining', 'videos_remaining', Icons.videocam_outlined),
  _Row('Duration budget (secs)', 'duration_secs_remaining', Icons.timer_outlined),
  _Row('Clip decodes', 'decode_remaining', Icons.code),
  _Row('Watermark removals', 'watermark_remaining', Icons.auto_fix_high),
  _Row('Avatars', 'avatars_remaining', Icons.person_outline),
  _Row('AI voices', 'voices_remaining', Icons.mic_none),
  _Row('Pictures', 'pictures_remaining', Icons.image_outlined),
  _Row('Chat credits today', 'daily_chat_remaining', Icons.chat_bubble_outline),
  _Row('Credit bank', 'credit_bank', Icons.savings_outlined),
];

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AppState>().refreshBalance());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: s.refreshBalance)],
      ),
      body: s.balance == null
          ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No active plan yet. Top up is coming in the next update.', textAlign: TextAlign.center)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final r in _rows)
                  Card(
                    child: ListTile(
                      leading: Icon(r.icon),
                      title: Text(r.label),
                      trailing: s.bal(r.key) <= 0 && r.key != 'credit_bank'
                          ? const Chip(label: Text('Upgrade'))
                          : Text('${s.bal(r.key)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
    );
  }
}
