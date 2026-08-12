import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';

class PageChat extends StatelessWidget {
  const PageChat({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: const Center(
        child: Text(
          "Чат",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}