import 'package:flutter/material.dart';
import 'package:intereasever2/appbar.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AppLayout({
    super.key,
    required this.child,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        showBackButton: showBackButton,
        onBackPressed: onBackPressed,
      ),

      backgroundColor: const Color(0xFF1B3146),

      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 375,
                height: MediaQuery.of(context).size.height * 1.1,
                color: const Color(0xFF99D98C).withAlpha(110),
              ),
            ),
          ),

          // 👇 сюда будет вставляться содержимое экрана
          child,
        ],
      ),
    );
  }
}