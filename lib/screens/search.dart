import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/services/search_service.dart';
import 'package:intereasever2/models/search_result.dart';
import 'package:intereasever2/dates/info_data.dart';
import 'package:intereasever2/info_detail_page.dart';
import 'package:intereasever2/screens/faqp.dart';
import 'package:intereasever2/dates/rvpo_fields.dart';
import 'package:intereasever2/dates/rvp_fields.dart';
import 'package:intereasever2/dates/vnzh_fields.dart';
import 'package:intereasever2/screens/document_form.dart';
import 'package:intereasever2/dates/plan.dart';
import 'package:intereasever2/dates/plan_dialogs.dart';

class PageSearch extends StatefulWidget {
  const PageSearch({super.key});

  @override
  State<PageSearch> createState() => _PageSearchState();
}

class _PageSearchState extends State<PageSearch> {

  final TextEditingController _searchController = TextEditingController();

  List<SearchResult> _results = [];

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Поиск",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            
            const SizedBox(height: 20),
            
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Введите ключевые слова",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white70,
                ),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
           Center(
            child: SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: () async {
                  final query = _searchController.text.trim();
                  final results = await SearchService.search(query);
                  
                  setState(() {
                    _results = results;
                  });
                },
                
                child: const Text("Найти"),
              ),
            ),
          ),
            
            const SizedBox(height: 30),
            
            const Text(
              "Результаты поиска",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),
            
            Expanded(
              
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(result.title),
                      subtitle: Text(
                        result.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      trailing: Text(result.section),

                      onTap: () async {
                        if (result.type == 'info') {
                          final item = infoItems.firstWhere(
                            (item) => item.title == result.id,
                          );
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InfoDetailPage(
                                item: item,
                              ),
                            ),
                          );
                        }
                        
                        if (result.type == 'faq') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PageFaq(
                                initialQuestion: result.id,
                              ),
                            ),
                          );
                        }
                        if (result.type == 'document') {
                          if (result.id == 'rvpo') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DocumentForm(
                                  title: 'Заявление на РВПО',
                                  templateName: 'rvpo',
                                  fields: rvpoFields,
                                ),
                              ),
                            );
                          }
                          
                          
                          if (result.id == 'rvp') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DocumentForm(
                                  title: 'Заявление на РВП',
                                  templateName: 'rvp',
                                  fields: rvpFields,
                                ),
                              ),
                            );
                          }
                          
                          if (result.id == 'vnzh') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DocumentForm(
                                  title: 'Заявление на ВНЖ',
                                  templateName: 'vnzh',
                                  fields: vnzhFields,
                                ),
                              ),
                            );
                          }
                        }

                        if (result.type == 'plan') {
                          final plan = await SearchService.getPlan(result.id);
                          if (plan != null && context.mounted) {
                            showPlanDialog(
                              context,
                              plan,
                              () async {},
                            );
                          }
                        }
                      },
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