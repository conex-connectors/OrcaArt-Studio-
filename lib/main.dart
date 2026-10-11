import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/api_config.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: ApiConfig.supabaseUrl, anonKey: ApiConfig.supabaseAnonKey);
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const OrcaArtApp()));
}

class OrcaArtApp extends StatelessWidget {
  const OrcaArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return MaterialApp(
      title: 'OrcaArt AI Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: s.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: s.loggedIn ? const ChatScreen() : const AuthScreen(),
    );
  }
}
