import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return data;
  }

  String getDisplayName(Map<String, dynamic>? profile, String? email) {
    final name = profile?['name'];
    final username = profile?['username'];

    if (name != null && name.toString().trim().isNotEmpty) {
      return name;
    }

    if (username != null && username.toString().trim().isNotEmpty) {
      return username;
    }

    return email ?? 'Гость';
  }
}