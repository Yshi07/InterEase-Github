import 'package:flutter/material.dart';
import 'package:intereasever2/models/document_field.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/template_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

class DocumentForm extends StatefulWidget {
  final String title;
  final String templateName;
  final List<DocumentField> fields;

  const DocumentForm({
    super.key,
    required this.title,
    required this.templateName,
    required this.fields,
  });

  @override
  State<DocumentForm> createState() => _DocumentFormState();
}

class _DocumentFormState extends State<DocumentForm> {
  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();

    // Создаем контроллер для каждого поля формы
    for (final field in widget.fields) {
      controllers[field.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: widget.fields.length,
                itemBuilder: (context, index) {
                  final field = widget.fields[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TextField(
                      controller: controllers[field.key],
                      decoration: InputDecoration(
                        labelText: field.title,
                        labelStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white30,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final values = <String, String>{};
                
                for (final entry in controllers.entries) {
                  
                  values[entry.key] = entry.value.text;
                }
                
                final file = await TemplateService().generateDocument(
                  templateName: widget.templateName,
                  values: values,
                );
                
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Документ создан"),
                      content: const Text(
                        "Что сделать с документом?",
                      ),
                      
                      actions: [
                        
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await OpenFilex.open(
                              file.path,
                            );
                          },
                          
                          child: const Text(
                            "Открыть",
                            
                          ),
                        ),
                        
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            
                            await Share.shareXFiles(
                              
                              [
                                XFile(file.path),
                              ],
                              text: widget.title,
                            );
                          },
                          
                          child: const Text(
                            "Поделиться",
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              
              child: const Text("Создать документ"),
            ),

          ],
        ),
      ),
    );
  }
}