import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/dates/faq_data.dart';
import 'package:intereasever2/faq_items.dart';

class PageFaq extends StatelessWidget {
  final String? initialQuestion;
  
  const PageFaq({
    super.key,
    this.initialQuestion,
  });

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
              
              return FaqTile(
                item: item,
                initiallyExpanded: initialQuestion == item.question,
              );
            },
          ),
        ),
      ),
    );
  }
}

class FaqTile extends StatelessWidget {
  final FAQItem item;
  final bool initiallyExpanded;

  const FaqTile({
    super.key,
    required this.item,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
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
  }
}