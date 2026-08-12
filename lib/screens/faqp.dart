import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/dates/faq_data.dart';

class PageFaq extends StatelessWidget {
  const PageFaq({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: Center(
        child: SizedBox(
          width: 375,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: faqData.length,
            itemBuilder: (context, index) {
              final item = faqData[index];
              
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    item.question,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.answer,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
               ),
              );
            },
          ),
        ),
      ),
    );
  }
}