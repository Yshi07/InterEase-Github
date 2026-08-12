import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';

class MyStudy extends StatelessWidget {
  const MyStudy({super.key});

  final String universityName =
      "Воронежский государственный\nлесотехнический университет\nим. Г.Ф. Морозова";

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              /// Университет
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 50,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        universityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              _buildSection(
                icon: Icons.contact_phone,
                title: "Контактная информация",
                items: [
                  "Деканат",
                  "Приемная комиссия",
                  "Международный отдел",
                ],
              ),

              const SizedBox(height: 20),

              _buildSection(
                icon: Icons.flash_on,
                title: "Быстрый доступ",
                items: [
                  "Сайт",
                  "Расписание",
                  "Библиотека",
                  "Moodle",
                  "Личный кабинет",
                  "Новости",
                ],
              ),

              const SizedBox(height: 20),

              _buildSection(
                icon: Icons.folder_open,
                title: "Нужное",
                items: [
                  "Справки",
                  "Заявления",
                  "Документы",
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> items,
  }) {
    final bool isExpandable = items.length > 3;

    return _ExpandableSection(
      icon: icon,
      title: title,
      items: items,
      isExpandable: isExpandable,
    );
  }
}

/// 🔥 ОТДЕЛЬНЫЙ ЧИСТЫЙ STATEFUL WIDGET
class _ExpandableSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final bool isExpandable;

  const _ExpandableSection({
    required this.icon,
    required this.title,
    required this.items,
    required this.isExpandable,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          InkWell(
            onTap: widget.isExpandable
                ? () {
                    setState(() {
                      isOpen = !isOpen;
                    });
                  }
                : null,
            child: Row(
              children: [
                Icon(widget.icon, color: Colors.white),
                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (widget.isExpandable)
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white54,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// CONTENT
          if (!widget.isExpandable || isOpen)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.items.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "• $e",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}