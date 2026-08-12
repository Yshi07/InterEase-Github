import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intereasever2/dates/plan.dart';


class PlanService {

  static Future<List<Plan>> loadPlans() async {
    final data = await Supabase.instance.client
        .from('plans')
        .select()
        .order('plan_date');

    return (data as List).map((item) {
      return Plan(
        id: item['id'],
        title: item['title'],
        content: item['content'] ?? '',
        date: DateTime.parse(item['plan_date']),
      );
    }).toList();
  }

}