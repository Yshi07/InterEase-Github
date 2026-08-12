import 'package:flutter/material.dart';
import 'package:intereasever2/info_items.dart';

class InfoDetailPage extends StatelessWidget {
  final InfoItem item;

  const InfoDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                    item.title,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                    item.content,
                    style: const TextStyle(fontSize: 16),
                ),
                
                const SizedBox(height: 30),
                
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Официальный источник'),
                    ),
                ),
            ],
        ),
      ),
    );
  }
}