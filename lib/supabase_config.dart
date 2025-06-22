import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://dpklqubuvjzovipojili.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRwa2xxdWJ1dmp6b3ZpcG9qaWxpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyMDIyNDcsImV4cCI6MjA2NTc3ODI0N30.xkUdgOUarUEK6jvcR3ufwtjcHAeS58kaWAuNtoYCW_E';

  static Future<void> init() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
