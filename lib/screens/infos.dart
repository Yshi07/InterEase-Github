import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/dates/info_data.dart';
import 'package:intereasever2/info_detail_page.dart';

class PageInfos extends StatelessWidget {
  const PageInfos({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        itemCount: infoItems.length,
        itemBuilder: (context, index) {
          final item = infoItems[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(item.title),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InfoDetailPage(
                      item: item,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}