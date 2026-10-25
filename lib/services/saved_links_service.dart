import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/saved_link.dart';

class SavedLinksService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Получить сохранённые ссылки текущего пользователя
  Future<List<SavedLink>> getSavedLinks({
    String section = 'useful',
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await _supabase
        .from('saved_links')
        .select()
        .eq('user_id', user.id)
        .eq('section', section)
        .order('created_at', ascending: false);

    return (response as List)
        .map((item) => SavedLink.fromMap(item))
        .toList();
  }

  // Добавить новую ссылку

  Future<void> addSavedLink({
    required String title,
    required String url,
    required String type,
    String section = 'useful',
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Пользователь не авторизован');
  }

    await _supabase.from('saved_links').insert({
      'user_id': user.id,
      'title': title,
      'url': url,
      'type': type,
      'section': section,
    });
  }


  // Удалить ссылку
  Future<void> deleteSavedLink(String id) async {
    await _supabase
        .from('saved_links')
        .delete()
        .eq('id', id);
  }
}