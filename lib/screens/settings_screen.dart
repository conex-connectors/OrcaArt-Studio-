import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _legal(BuildContext c, String title, String body) {
    showDialog(
      context: c,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _logout(BuildContext c, AppState s) async {
    final ok = await showDialog<bool>(
      context: c,
      builder: (_) => AlertDialog(
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes')),
        ],
      ),
    );
    if (ok == true) {
      await s.signOut();
      if (c.mounted) Navigator.popUntil(c, (r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(leading: const Icon(Icons.person_outline), title: Text(s.username), subtitle: Text(s.email)),
          SwitchListTile(secondary: const Icon(Icons.dark_mode_outlined), title: const Text('Dark mode'), value: s.darkMode, onChanged: s.setDark),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('Terms of Service'),
            onTap: () => _legal(context, 'Terms of Service', 'By using OrcaArt AI Studio you agree to use it lawfully. Purchases are processed by our payment partner and are non-refundable. Content you generate is yours, subject to the licences of the underlying AI models.'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            onTap: () => _legal(context, 'Privacy Policy', 'We store your email, username, usage and generated media to run the service. Payments are handled by our payment partner. We do not sell your data.'),
          ),
          ListTile(leading: const Icon(Icons.logout, color: Color(0xFFFF7A7A)), title: const Text('Log out', style: TextStyle(color: Color(0xFFFF7A7A))), onTap: () => _logout(context, s)),
        ],
      ),
    );
  }
}
