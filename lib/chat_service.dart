import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> sendMessage(String text) async {
    final session =
        Supabase.instance.client.auth.currentSession;

    if (session == null) {
      throw Exception('Пользователь не авторизован');
    }

    final userId = session.user.id;
    final accessToken = session.accessToken;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/chat'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': text,
        'session_id': sessionId,
        'user_id': userId,
        'access_token': accessToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    }

    throw Exception('Ошибка подключения');
  }
}