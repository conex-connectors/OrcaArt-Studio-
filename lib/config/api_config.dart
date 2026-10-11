class ApiConfig {
  static const String baseUrl = String.fromEnvironment('API_BASE', defaultValue: 'https://orcaart-api.orcaart-hub.workers.dev');
  static const String supabaseUrl = 'https://klbzykymyabeczzvhjpu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtsYnp5a3lteWFiZWN6enZoanB1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk4MDg0MDEsImV4cCI6MjEwNTM4NDQwMX0.6wUkRblAIaNbjnU5sTi156PnAjXX1s96JBqKdon_bLs';
  static const String health = '$baseUrl/api/health';
  static const String chat = '$baseUrl/api/chat';
  static const String generateVideo = '$baseUrl/api/generate/video';
  static const String generateImage = '$baseUrl/api/generate/image';
  static const String checkout = '$baseUrl/api/checkout';
  static const String balance = '$baseUrl/api/balance';
  static const String library = '$baseUrl/api/library';
  static const String decode = '$baseUrl/api/decode';
  static const String voices = '$baseUrl/api/voices';
  static const String avatars = '$baseUrl/api/avatars';
  static const String chats = '$baseUrl/api/chats';
}
