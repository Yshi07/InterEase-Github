import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intereasever2/dates/plan.dart';
import 'package:intereasever2/screens/myplans.dart';


Future<void> showEditPlanDialog(
  BuildContext context,
  Plan plan,
  Future<void> Function() reload,
) async {
  final titleController = TextEditingController(text: plan.title);
  final contentController = TextEditingController(text: plan.content);
  DateTime selectedDate = plan.date;

  await showDialog(
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
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'Текст заметки',
                    alignLabelWithHint: true,
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

              await Supabase.instance.client
                  .from('plans')
                  .update({
                    'title': titleController.text.trim(),
                    'content': contentController.text.trim(),
                    'plan_date': selectedDate.toIso8601String(),
                  })
                  .eq('id', plan.id);

              Navigator.pop(context);

              await reload(); // 🔥 обновление из MyPlans или main
            },
            child: const Text('Сохранить'),
          ),
        ],
      );
    },
  );
}

Future<void> showPlanDialog(
  BuildContext context,
  Plan plan,
  Future<void> Function() reload,
) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(plan.title),
      content: Text(plan.content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showEditPlanDialog(context, plan, reload);
          },
          child: const Text('Редактировать'),
        ),
      ],
    ),
  );
}