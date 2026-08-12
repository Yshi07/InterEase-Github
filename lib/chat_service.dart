import 'dart:convert';
import 'package:http/http.dart' as http;


class ChatService {
  String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> sendMessage(String text) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/chat'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'message': text,
        'session_id': sessionId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    }

    throw Exception('Ошибка подключения');
  }
}