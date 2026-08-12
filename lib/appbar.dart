import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
      
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      height: 100 + statusBarHeight,

      child: Column(
        children: [

          SizedBox(height: statusBarHeight),

          SizedBox(
            height: 100,

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                Flexible(
                  child: Container(
                    color: const Color(0xFF1B3146),
                  ),
                ),

                Container(
                  width: 375,
                  color: const Color(0xFF4F6D7A),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [

                      /// Левая часть
                      Row(
                        children: [

                          /// Кнопка назад
                          if (showBackButton)
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: onBackPressed ??
                              () {
                                Navigator.pop(context);
                              },
                            ),

                          const Padding(
                            padding: EdgeInsets.only(left: 8),

                            child: Text(
                              "InterEase",

                              style: TextStyle(
                                color: Color(0xFFFF8400),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// Флаг справа
                      Padding(
                        padding: const EdgeInsets.only(right: 20),

                        child: Image.asset(
                          'assets/russian_flag.png',
                          width: 50,
                        ),
                      ),
                    ],
                  ),
                ),

                Flexible(
                  child: Container(
                    color: const Color(0xFF1B3146),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}