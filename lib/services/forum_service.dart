import 'package:supabase_flutter/supabase_flutter.dart';

class ForumService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Получить все сообщения форума
  Future<List<Map<String, dynamic>>> getPosts() async {
    final response = await _supabase
        .from('forum_posts')
        .select(
          'id, user_id, content, created_at, author_name, is_deleted, reply_to',
        )
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Добавить новое сообщение
  Future<void> addPost(
    String content, {
    String? replyTo,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    final profile = await _supabase
        .from('profiles')
        .select('name, surname, username')
        .eq('id', user.id)
        .single();

    final name = profile['name']?.toString().trim() ?? '';
    final surname = profile['surname']?.toString().trim() ?? '';
    final username = profile['username']?.toString().trim() ?? '';

    String authorName;

    if (name.isNotEmpty || surname.isNotEmpty) {
      authorName = '$name $surname'.trim();
    } else if (username.isNotEmpty) {
      authorName = username;
    } else {
      authorName = 'Пользователь';
    }

    await _supabase.from('forum_posts').insert({
      'user_id': user.id,
      'content': content,
      'author_name': authorName,
      'reply_to': replyTo,
    });
  }

  Future<void> deletePost(String postId) async {
    final user = _supabase.auth.currentUser;
    
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    // Проверяем, есть ли ответы на это сообщение
    final replies = await _supabase
        .from('forum_posts')
        .select('id')
        .eq('reply_to', postId);

    if (replies.isEmpty) {
      // Ответов нет — удаляем сообщение полностью
      await _supabase
          .from('forum_posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', user.id);
    } else {
      // Есть ответы — оставляем сообщение в БД,
      // но помечаем его как удалённое
      await _supabase
          .from('forum_posts')
          .update({'is_deleted': true})
          .eq('id', postId)
          .eq('user_id', user.id);
    }
  }
}