import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  String? _token;
  void setToken(String t) => _token = t;
  void clearToken() => _token = null;
  bool get hasToken => _token != null;

  Map<String, String> get _h => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> _get(String url) async {
    final r = await http
        .get(Uri.parse(url), headers: _h)
        .timeout(const Duration(seconds: 30));
    return _parse(r);
  }

  Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> body) async {
    final r = await http
        .post(Uri.parse(url), headers: _h, body: jsonEncode(body))
        .timeout(const Duration(seconds: 60));
    return _parse(r);
  }

  Future<Map<String, dynamic>> _delete(String url, [Map<String, dynamic>? body]) async {
    final r = await http
        .delete(Uri.parse(url),
            headers: _h, body: body != null ? jsonEncode(body) : null)
        .timeout(const Duration(seconds: 30));
    return _parse(r);
  }

  Map<String, dynamic> _parse(http.Response r) {
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode >= 400) {
      throw ApiException((data['error'] ?? 'Failed').toString(), r.statusCode);
    }
    return data;
  }

  Future<bool> ping() async {
    try {
      final r = await _get(ApiConfig.health);
      return r['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  Future<String> chat({required String message, String? chatId, String? systemContext}) async {
    final r = await _post(ApiConfig.chat, {
      'message': message,
      if (chatId != null) 'chat_id': chatId,
      if (systemContext != null) 'system_context': systemContext,
    });
    return r['reply'] as String? ?? '';
  }

  Future<Map<String, dynamic>> generateVideo({
    required String prompt,
    int durationSecs = 15,
    String quality = '480p',
    String ratio = '16:9',
    int quantity = 1,
    bool isAd = false,
  }) {
    return _post(ApiConfig.generateVideo, {
      'prompt': isAd ? '[AD] $prompt' : prompt,
      'duration_secs': durationSecs,
      'quality': quality,
      'ratio': ratio,
      'quantity': quantity,
    });
  }

  Future<Map<String, dynamic>> generateImage({required String prompt}) {
    return _post(ApiConfig.generateImage, {'prompt': prompt});
  }

  Future<Map<String, dynamic>?> getBalance() async {
    final r = await _get(ApiConfig.balance);
    return r['balance'] as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getLibrary({String? type}) async {
    final url = type != null ? '${ApiConfig.library}?type=$type' : ApiConfig.library;
    final r = await _get(url);
    return (r['items'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  Future<void> deleteLibraryItem(String id) async {
    await _delete(ApiConfig.library, {'id': id});
  }

  Future<String> decode({required String videoUrl, String mode = 'script'}) async {
    final r = await _post(ApiConfig.decode, {'video_url': videoUrl, 'mode': mode});
    return r['result'] as String? ?? '';
  }

  Future<List<Map<String, dynamic>>> getVoices() async {
    final r = await _get(ApiConfig.voices);
    return (r['voices'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getAvatars() async {
    final r = await _get(ApiConfig.avatars);
    return (r['avatars'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getChats() async {
    final r = await _get(ApiConfig.chats);
    return (r['chats'] as List? ?? []).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> createChat(String title) async {
    final r = await _post(ApiConfig.chats, {'title': title});
    return r['chat'] as Map<String, dynamic>?;
  }

  Future<void> deleteChat({String? id, bool deleteAll = false}) async {
    await _delete(ApiConfig.chats, deleteAll ? {'delete_all': true} : {'id': id});
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException(this.message, this.statusCode);
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  @override
  String toString() => 'ApiException($statusCode): $message';
}
