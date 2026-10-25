import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intereasever2/models/news_article.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class NewsApiService {
  // final String baseUrl = 'http://192.168.1.116:8000'; // телефон
  final String baseUrl = 'http://10.0.2.2:8000'; // эмулятор

  Future<List<NewsArticle>> getNews() async {

    final user = Supabase.instance.client.auth.currentUser;
    final session = Supabase.instance.client.auth.currentSession;

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Если пользователь авторизован —
    // передаём его данные на FastAPI.
    if (user != null && session != null) {
      headers['user_id'] = user.id;
      headers['access_token'] = session.accessToken;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/news'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Ошибка загрузки новостей: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    final articles = List<Map<String, dynamic>>.from(
      data['articles'],
    );

    return articles
        .map((article) => NewsArticle.fromMap(article))
        .toList();
  }
}