import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() => runApp(const OrcaArtApp());

class OrcaArtApp extends StatelessWidget {
  const OrcaArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrcaArt AI Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020403),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF2EE6C4)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _status = 'Tap the button to test the OrcaArt API';
  bool _busy = false;

  Future<void> _check() async {
    setState(() {
      _busy = true;
      _status = 'Checking...';
    });
    final ok = await ApiService().ping();
    var extra = '';
    if (ok) {
      try {
        final voices = await ApiService().getVoices();
        extra = ' - ${voices.length} AI voices';
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = ok ? 'API online$extra' : 'API unreachable';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('OrcaArt AI Studio',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              Text(_status, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _check,
                child: const Text('Test API'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
