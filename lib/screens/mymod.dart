import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/dates/rvpo_fields.dart';
import 'package:intereasever2/screens/document_form.dart';
import 'package:intereasever2/models/document_field.dart';
import 'package:intereasever2/dates/vnzh_fields.dart';
import 'package:intereasever2/dates/rvp_fields.dart';


class DocumentTemplate {
  final String id;
  final String title;
  final IconData icon;
  final List<DocumentField> fields;

  const DocumentTemplate({
    required this.id,
    required this.title,
    required this.icon,
    required this.fields,
  });
}

class MyMod extends StatelessWidget {
  const MyMod({super.key});

  @override
  Widget build(BuildContext context) {
    const List<DocumentTemplate> templates = [
      DocumentTemplate(
        id: "rvpo",
        title: "Заявление на РВПО",
        icon: Icons.description_outlined,
        fields: rvpoFields,
      ),
      DocumentTemplate(
        id: "rvp",
        title: "Заявление на РВП",
        icon: Icons.description_outlined,
        fields: rvpFields,
      ),
      DocumentTemplate(
        id: "vnzh",
        title: "Заявление на ВНЖ",
        icon: Icons.description_outlined,
        fields: vnzhFields,
      ),
      DocumentTemplate(
        id: "registration",
        title: "Бланк регистрации",
        icon: Icons.article_outlined,
        fields: [],
      ),
    ];

    return AppLayout(
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Шаблоны документов",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      color: const Color(0xFF29435C),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        leading: Icon(
                          template.icon,
                          color: Colors.white,
                          size: 30,
                        ),
                        title: Text(
                          template.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white70,
                          size: 18,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DocumentForm(
                                title: template.title,
                                templateName: template.id,
                                fields: template.fields,
                              ),
                            ),
                          );
                        },
                        
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}