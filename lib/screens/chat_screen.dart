import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'balance_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';
import 'video_adj_sheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _run(Future<void> Function(String) action) async {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    _text.clear();
    final f = action(t);
    _toBottom();
    await f;
    _toBottom();
  }

  void _open(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _drawer(AppState s) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(s.username), subtitle: Text(s.email)),
            const Divider(),
            ListTile(leading: const Icon(Icons.account_balance_wallet_outlined), title: const Text('Balance'), onTap: () => _open(const BalanceScreen())),
            ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Library'), onTap: () => _open(const LibraryScreen())),
            ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () => _open(const SettingsScreen())),
          ],
        ),
      ),
    );
  }

  Widget _bubble(ChatMsg m) {
    final user = m.role == 'user';
    final system = m.role == 'system';
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: user ? cs.primary : (system ? const Color(0x26FF7A7A) : Theme.of(context).cardColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(m.text, style: TextStyle(color: user ? Colors.black : (system ? const Color(0xFFFF7A7A) : null))),
            if (m.url != null && !m.isVideo)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(m.url!, errorBuilder: (_, __, ___) => const Text('Image saved to Library')),
                ),
              ),
            if (m.url != null && m.isVideo)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.play_circle_outline, size: 18), SizedBox(width: 6), Text('Saved to Library')]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _composer(AppState s) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _text, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Describe your video or image...')),
            Row(
              children: [
                IconButton(
                  tooltip: 'Video settings',
                  icon: const Icon(Icons.tune),
                  onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => const VideoAdjSheet()),
                ),
                TextButton.icon(icon: const Icon(Icons.movie_outlined, size: 18), label: const Text('Video'), onPressed: () => _run(s.generateVideo)),
                TextButton.icon(icon: const Icon(Icons.image_outlined, size: 18), label: const Text('Image'), onPressed: () => _run(s.generateImage)),
                const Spacer(),
                IconButton.filled(tooltip: 'Send', icon: const Icon(Icons.arrow_upward), onPressed: () => _run(s.send)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final count = s.messages.length + (s.thinking ? 1 : 0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('OrcaArt', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(tooltip: 'New chat', icon: const Icon(Icons.add_comment_outlined), onPressed: s.newChat)],
      ),
      drawer: _drawer(s),
      body: Column(
        children: [
          Expanded(
            child: s.messages.isEmpty && !s.thinking
                ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Describe the video or image you want to create. Tap Video or Image to generate, or Send to chat with Orca.', textAlign: TextAlign.center)))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: count,
                    itemBuilder: (_, i) => i == s.messages.length ? _bubble(const ChatMsg('ai', 'Working on it...')) : _bubble(s.messages[i]),
                  ),
          ),
          _composer(s),
        ],
      ),
    );
  }
}
