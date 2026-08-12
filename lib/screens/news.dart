import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';

class PageNews extends StatelessWidget {
  const PageNews({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: const Center(
        child: Text(
          "Новости",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}