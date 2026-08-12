import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';

class PageSearch extends StatelessWidget {
  const PageSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: const Center(
        child: Text(
          "Поиск",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}