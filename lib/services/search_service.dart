import 'package:intereasever2/dates/faq_data.dart';
import 'package:intereasever2/dates/info_data.dart';
import 'package:intereasever2/models/search_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intereasever2/dates/plan.dart';

class SearchService {

  static List<SearchResult> searchFAQ(String query) {
    final results = <SearchResult>[];

    final searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      return results;
    }

    for (final item in faqData) {
      final question = item.question.toLowerCase();
      final answer = item.answer.toLowerCase();

      if (question.contains(searchQuery) ||
          answer.contains(searchQuery)) {

        results.add(
          SearchResult(
            title: item.question,
            content: item.answer,
            section: 'FAQ',
            type: 'faq',
            id: item.question,
          ),
        );
      }
    }

    return results;
  }
  
  static List<SearchResult> searchInfo(String query) {
    final results = <SearchResult>[];

    final searchQuery = query.toLowerCase().trim();

    if (searchQuery.isEmpty) {
      return results;
    }

    for (final item in infoItems) {
      final title = item.title.toLowerCase();
      final content = item.content.toLowerCase();

      if (title.contains(searchQuery) ||
          content.contains(searchQuery)) {

        results.add(
          SearchResult(
            title: item.title,
            content: item.content,
            section: 'Полезная информация',
            type: 'info',
            id: item.title,
          ),
        );
      }
    }

    return results;
  }

    static List<SearchResult> searchDocuments(String query) {
      final results = <SearchResult>[];

      final searchQuery = query.toLowerCase().trim();

      if (searchQuery.isEmpty) {
        return results;
      }

      final documents = [
        {
          'id': 'rvpo',
          'title': 'Заявление на РВПО',
        },
        {
          'id': 'rvp',
          'title': 'Заявление на РВП',
        },
        {
          'id': 'vnzh',
          'title': 'Заявление на ВНЖ',
        },
        {
          'id': 'registration',
          'title': 'Бланк регистрации',
        },
      ];

      for (final document in documents) {
        final title = document['title']!.toLowerCase();

        if (title.contains(searchQuery)) {
          results.add(
            SearchResult(
              title: document['title']!,
              content: 'Шаблон документа',
              section: 'Шаблоны документов',
              type: 'document',
              id: document['id']!,
            ),
          );
        }
      }

      return results;
    }

    static Future<List<SearchResult>> searchPlans(String query) async {
      final results = <SearchResult>[];
    
      final searchQuery = query.toLowerCase().trim();
    
      if (searchQuery.isEmpty) {
        return results;
      }
    
      final user = Supabase.instance.client.auth.currentUser;
    
      if (user == null) {
        return results;
      }
    
    
      final data = await Supabase.instance.client
          .from('plans')
          .select()
          .eq('user_id', user.id);

      for (final plan in data) {
        final title = (plan['title'] ?? '').toString();
        final content = (plan['content'] ?? '').toString();

        if (title.toLowerCase().contains(searchQuery) ||
            content.toLowerCase().contains(searchQuery)) {
          results.add(
            SearchResult(
              title: title,
              content: content,
              section: 'Мои заметки',
              type: 'plan',
              id: plan['id'].toString(),
            ),
          );
            }
      }

      return results;
      }

    static Future<Plan?> getPlan(String id) async {
      final user = Supabase.instance.client.auth.currentUser;
      
      if (user == null) {
        return null;
      }
      
      final data = await Supabase.instance.client
          .from('plans')
          .select()
          .eq('id', id)
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null) {
        return null;
      }
      
      return Plan(
        id: data['id'].toString(),
        title: data['title'] ?? '',
        content: data['content'] ?? '',
        date: DateTime.parse(data['plan_date']),
      );
    }

  static Future<List<SearchResult>> search(String query) async {
    final results = <SearchResult>[];
    
    results.addAll(searchFAQ(query));
    results.addAll(searchInfo(query));
    
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      print("SEARCH USER: ${user.id}");
      
      results.addAll(searchDocuments(query));
      
      final planResults = await searchPlans(query);
      
      results.addAll(planResults);

    } else {
      print("SEARCH USER: guest");
    }
    
    return results;
  }
}

