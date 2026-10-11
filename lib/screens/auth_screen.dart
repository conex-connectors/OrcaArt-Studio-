import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  bool _accepted = false;
  String? _msg;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _pass.text.isEmpty) {
      setState(() => _msg = 'Enter your email and password.');
      return;
    }
    if (_signUp) {
      if (_pass.text.length < 8) {
        setState(() => _msg = 'Password must be at least 8 characters.');
        return;
      }
      if (!_accepted) {
        setState(() => _msg = 'Please accept the Terms of Service and Privacy Policy.');
        return;
      }
    }
    setState(() {
      _busy = true;
      _msg = null;
    });
    final auth = Supabase.instance.client.auth;
    try {
      if (_signUp) {
        final res = await auth.signUp(email: _email.text.trim(), password: _pass.text, data: {'username': _name.text.trim()});
        if (res.session == null) _msg = 'Check your email to confirm your account, then sign in.';
      } else {
        await auth.signInWithPassword(email: _email.text.trim(), password: _pass.text);
      }
    } on AuthException catch (e) {
      _msg = e.message;
    } catch (_) {
      _msg = 'Something went wrong. Check your connection.';
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('OrcaArt AI Studio', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(_signUp ? 'Create your account' : 'Welcome back', textAlign: TextAlign.center),
                const SizedBox(height: 28),
                if (_signUp) ...[
                  TextField(controller: _name, decoration: const InputDecoration(hintText: 'Username')),
                  const SizedBox(height: 12),
                ],
                TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(hintText: 'Password')),
                if (_signUp)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _accepted,
                    onChanged: (v) => setState(() => _accepted = v ?? false),
                    title: const Text('I have read and accept the Terms of Service and Privacy Policy', style: TextStyle(fontSize: 13)),
                  ),
                if (_msg != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_msg!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFF7A7A))),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_signUp ? 'Create account' : 'Sign in'),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _signUp = !_signUp;
                    _msg = null;
                  }),
                  child: Text(_signUp ? 'Already have an account? Sign in' : 'New here? Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
