import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/models/saved_link.dart';
import 'package:intereasever2/services/saved_links_service.dart';

class MyUse extends StatefulWidget {
  const MyUse({super.key});

  @override
  State<MyUse> createState() => _MyUseState();
}

class _MyUseState extends State<MyUse> {
  final SavedLinksService _savedLinksService = SavedLinksService();

  List<SavedLink> _savedLinks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLinks();
  }

  Future<void> _loadSavedLinks() async {
    try {
      final links = await _savedLinksService.getSavedLinks();

      if (!mounted) return;

      setState(() {
        _savedLinks = links;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось загрузить ссылки: $e'),
        ),
      );
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'telegram':
        return Icons.send;
      case 'vk':
        return Icons.people;
      case 'facebook':
        return Icons.facebook;
      default:
        return Icons.language;
    }
  }

  Future<void> _deleteLink(String id) async {
    try {
      await _savedLinksService.deleteSavedLink(id);

      if (!mounted) return;

      setState(() {
        _savedLinks.removeWhere((link) => link.id == id);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось удалить ссылку: $e'),
        ),
      );
    }
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Некорректная ссылка'),
        ),
      );
      return;
    }

    final success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось открыть ссылку'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Всякое полезное',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Рекомендации для вас',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Здесь появятся рекомендации, '
                  'подобранные специально для вас.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Мои сохранённые ссылки',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (_savedLinks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Вы пока ничего не сохранили.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                ..._savedLinks.map(
                  (link) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () => _openLink(link.url),
                      leading: Icon(
                        _getIcon(link.type),
                        size: 30,
                      ),
                      title: Text(link.title),
                      subtitle: Text(
                        link.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteLink(link.id),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showAddLinkDialog,
                    icon: const Icon(Icons.add_link),
                    label: const Text('Добавить ссылку'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _detectLinkType(String url) {
    final lowerUrl = url.toLowerCase();
    
    if (lowerUrl.contains('t.me') ||
        lowerUrl.contains('telegram.me') ||
        lowerUrl.contains('telegram.org')) {
      return 'telegram';
    }

    if (lowerUrl.contains('vk.com') ||
        lowerUrl.contains('vkontakte.ru')) {
      return 'vk';
    }

    if (lowerUrl.contains('facebook.com') ||
        lowerUrl.contains('fb.com')) {
      return 'facebook';
    }

    return 'website';
  }

  Future<void> _showAddLinkDialog() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить ссылку'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Например, Telegram студентов',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Ссылка',
                  hintText: 'https://...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final url = urlController.text.trim();

                if (title.isEmpty || url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Заполните название и ссылку'),
                    ),
                  );
                  return;
                }

                try {
                  final type = _detectLinkType(url);

                  await _savedLinksService.addSavedLink(
                    title: title,
                    url: url,
                    type: type,
                  );

                  if (!mounted) return;

                  Navigator.pop(context);
                  await _loadSavedLinks();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ссылка сохранена'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Не удалось сохранить ссылку: $e'),
                    ),
                  );
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }
}