import 'package:supabase_flutter/supabase_flutter.dart';

class UniversityService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> searchUniversities(
    String query,
  ) async {
    final search = query.trim();

    if (search.isEmpty) {
      return [];
    }

    final data = await _client
        .from('universities')
        .select('id, full_name, short_name, region')
        .or(
          'short_name.ilike.%$search%,full_name.ilike.%$search%',
        )
        .limit(20);

    return List<Map<String, dynamic>>.from(data);
  }
}