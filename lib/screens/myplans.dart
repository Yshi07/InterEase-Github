import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/dates/plan.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intereasever2/dates/plan_dialogs.dart';

class MyPlans extends StatefulWidget {
  const MyPlans({super.key});

  @override
  State<MyPlans> createState() => _MyPlansState();
}

class _MyPlansState extends State<MyPlans> {
  final List<Plan> plans = [];

  Future<void> loadPlans() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    
    final data = await Supabase.instance.client
        .from('plans')
        .select()
        .eq('user_id', userId)
        .order('plan_date');

    setState(() {
      plans.clear();
      plans.addAll(
        (data as List).map((item) => Plan(
          id: item['id'],
          title: item['title'],
          content: item['content'] ?? '',
          date: DateTime.parse(item['plan_date']),
        )),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    loadPlans();
    
  }

  void _showAddPlanDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Заметка'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Название',
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Текст заметки',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2035),
                      );

                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: const Text('Выбрать дату'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;

                  final userId = Supabase.instance.client.auth.currentUser!.id;
                  
                  await Supabase.instance.client.from('plans').insert({
                    'title': titleController.text.trim(),
                    'content': contentController.text.trim(),
                    'plan_date': selectedDate.toIso8601String(),
                    'user_id': userId,
                  });

                  Navigator.pop(context);
                  
                  loadPlans();
              },

              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddPlanDialog,
          child: const Icon(Icons.add),
        ),
        body: plans.isEmpty
            ? const Center(
                child: Text(
                  'Создай заметку',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];


                  return Dismissible(
                    key: Key(plan.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.grey,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    
                    confirmDismiss: (direction) async {
                      await Supabase.instance.client
                          .from('plans')
                          .delete()
                          .eq('id', plan.id);
                      loadPlans();
                      return true;
                    },
                    
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(plan.title),
                        subtitle: Text(
                          '${plan.date.day}.${plan.date.month}.${plan.date.year}',
                        ),
                      
                        onTap: () {
                          showPlanDialog(
                            context,
                            plan,
                            loadPlans,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}