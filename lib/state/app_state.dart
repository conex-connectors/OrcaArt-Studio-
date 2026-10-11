import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class ChatMsg {
  final String role;
  final String text;
  final String? url;
  final bool isVideo;
  const ChatMsg(this.role, this.text, {this.url, this.isVideo = false});
}

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();
  final SupabaseClient _sb = Supabase.instance.client;

  Session? _session;
  Map<String, dynamic>? balance;
  bool darkMode = true;
  bool thinking = false;
  String? chatId;
  final List<ChatMsg> messages = [];

  int duration = 15;
  int quality = 0;
  String ratio = '16:9';
  int quantity = 1;
  bool marketing = false;

  AppState() {
    _session = _sb.auth.currentSession;
    _onSession();
    _sb.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      _onSession();
      notifyListeners();
    });
  }

  bool get loggedIn => _session != null;
  String get email => _session?.user.email ?? '';
  String get username => (_session?.user.userMetadata?['username'] as String?) ?? email.split('@').first;
  String get qualityLabel => const ['480p', '720p', '1080p'][quality];
  int get creditCost => (duration / 15).ceil();

  void _onSession() {
    final s = _session;
    if (s != null) {
      _api.setToken(s.accessToken);
      refreshBalance();
    } else {
      _api.clearToken();
      balance = null;
      messages.clear();
      chatId = null;
    }
  }

  Future<void> refreshBalance() async {
    try {
      balance = await _api.getBalance();
    } catch (_) {}
    notifyListeners();
  }

  int bal(String key) => (balance?[key] as num?)?.toInt() ?? 0;

  void setDark(bool v) {
    darkMode = v;
    notifyListeners();
  }

  void updateVideo({int? d, int? q, String? r, int? n, bool? m}) {
    if (d != null) duration = d;
    if (q != null) quality = q;
    if (r != null) ratio = r;
    if (n != null) quantity = n;
    if (m != null) marketing = m;
    notifyListeners();
  }

  void newChat() {
    messages.clear();
    chatId = null;
    notifyListeners();
  }

  Future<void> signOut() => _sb.auth.signOut();

  String _context() {
    final mode = marketing ? 'Marketing agent is ON: the user is making ads.' : 'Creative agent: original content, no ads.';
    return 'You are Orca, the assistant inside OrcaArt AI Studio. Help the user plan videos and images. $mode Video settings: $qualityLabel, $ratio, ${duration}s, quantity $quantity. Generated media is saved to the Library.';
  }

  Future<void> send(String text) async {
    messages.add(ChatMsg('user', text));
    thinking = true;
    notifyListeners();
    try {
      chatId ??= (await _api.createChat('New chat'))?['id'] as String?;
      final reply = await _api.chat(message: text, chatId: chatId, systemContext: _context());
      messages.add(ChatMsg('ai', reply));
    } on ApiException catch (e) {
      messages.add(ChatMsg('system', e.message));
    } catch (_) {
      messages.add(ChatMsg('system', 'Could not reach the OrcaArt server. Check your connection.'));
    }
    thinking = false;
    notifyListeners();
    refreshBalance();
  }

  Future<void> generateVideo(String prompt) => _generate(prompt, true);
  Future<void> generateImage(String prompt) => _generate(prompt, false);

  Future<void> _generate(String prompt, bool video) async {
    messages.add(ChatMsg('user', '${video ? 'Video' : 'Image'}: $prompt'));
    thinking = true;
    notifyListeners();
    try {
      final r = video
          ? await _api.generateVideo(prompt: prompt, durationSecs: duration, quality: qualityLabel, ratio: ratio, quantity: quantity, isAd: marketing)
          : await _api.generateImage(prompt: prompt);
      messages.add(ChatMsg('ai', video ? 'Your video is ready. Find it in your Library.' : 'Your image is ready.', url: r['url'] as String?, isVideo: video));
    } on ApiException catch (e) {
      messages.add(ChatMsg('system', e.message));
    } catch (_) {
      messages.add(ChatMsg('system', 'Generation failed. Please try again.'));
    }
    thinking = false;
    notifyListeners();
    refreshBalance();
  }
}
