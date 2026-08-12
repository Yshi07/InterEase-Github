import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';

class MyUse extends StatelessWidget {
  const MyUse({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: const Center(
        child: Text(
          "Всякое полезное",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}