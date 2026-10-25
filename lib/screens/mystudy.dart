import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/screens/university_search.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intereasever2/models/saved_link.dart';
import 'package:intereasever2/services/saved_links_service.dart';

class MyStudy extends StatefulWidget {
  const MyStudy({super.key});

  @override
  State<MyStudy> createState() => _MyStudyState();
}

class _MyStudyState extends State<MyStudy> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? university;

  bool isLoading = true;

  final SavedLinksService _savedLinksService = SavedLinksService();
  
  List<SavedLink> _universityLinks = [];
  bool _linksLoading = true;

  @override
  void initState() {
    super.initState();
    loadUniversity();
    loadUniversityLinks();
  }

  Future<void> loadUniversityLinks() async {
    try {
      final links = await _savedLinksService.getSavedLinks(
        section: 'university',
      );

      if (!mounted) return;
      
      setState(() {
        _universityLinks = links;
        _linksLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _linksLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось загрузить ссылки: $e'),
        ),
      );
    }
  }

  Future<void> _showAddUniversityLinkDialog() async {

    await showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final urlController = TextEditingController();
        return AlertDialog(
          title: const Text("Добавить ссылку"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Название",
                  hintText: "Например: Moodle",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: "Ссылка",
                  hintText: "https://...",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Отмена"),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final url = urlController.text.trim();

                if (title.isEmpty || url.isEmpty) {
                  return;
                }

                try {
                  await _savedLinksService.addSavedLink(
                    title: title,
                    url: url,
                    type: 'website',
                    section: 'university',
                  );

                  if (!mounted) return;
                  
                  Navigator.pop(context);
                  
                  await Future.delayed(const Duration(milliseconds: 100));
                  
                  if (!mounted) return;
                  
                  await loadUniversityLinks();
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Не удалось добавить ссылку: $e"),
                    ),
                  );
                }
              },
              child: const Text("Добавить"),
            ),
          ],
        );
      },
    );
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

  Future<void> loadUniversity() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Сначала узнаём, какой university_id
      // записан у пользователя в профиле
      final profile = await supabase
          .from('profiles')
          .select('university_id')
          .eq('id', user.id)
          .single();

      final universityId = profile['university_id'];

      // Если университет не указан
      if (universityId == null) {
        setState(() {
          university = null;
          isLoading = false;
        });
        return;
      }

      // Если университет указан —
      // получаем его данные из таблицы universities
      final result = await supabase
          .from('universities')
          .select(
            'id, full_name, short_name, region, address, phone, email, website',
          )
          .eq('id', universityId)
          .single();

      setState(() {
        university = result;
        isLoading = false;
      });
    } catch (e) {
      print('ОШИБКА ЗАГРУЗКИ УНИВЕРСИТЕТА: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> selectUniversity() async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const UniversitySearch(),
      ),
    );

    if (result == null) return;

    final shortName =
        (result['short_name'] ?? '').toString().split(',').first.trim();

    try {
      // Сохраняем выбранный университет
      // и в новый university_id,
      // и пока ещё в старое текстовое поле university
      await supabase.from('profiles').update({
        'university_id': result['id'],
        'university': shortName,
      }).eq('id', user.id);

      setState(() {
        university = result;
        isLoading = false;
      });
    } catch (e) {
      print('ОШИБКА СОХРАНЕНИЯ УНИВЕРСИТЕТА: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось сохранить университет: $e'),
        ),
      );
    }
  }

  Widget _buildUniversityCard() {
    // Университет ещё не выбран
    if (university == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 50,
            ),

            const SizedBox(height: 15),

            const Text(
              'Университет',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Вы ещё не указали университет',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: selectUniversity,
              child: const Text('Выбрать университет'),
            ),
          ],
        ),
      );
    }

    // Университет уже выбран
    return Container(
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
              university!['full_name'] ?? '',
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
    );
  }

  Widget _buildContactSection() {
    final data = university!;

    final List<String> contacts = [];

    final address = data['address'];
    final phone = data['phone'];
    final email = data['email'];

    if (address != null && address.toString().trim().isNotEmpty) {
      contacts.add('📍 ${address.toString().trim()}');
    }

    if (phone != null && phone.toString().trim().isNotEmpty) {
      contacts.add('☎ ${phone.toString().trim()}');
    }

    if (email != null && email.toString().trim().isNotEmpty) {
      contacts.add('✉ ${email.toString().trim()}');
    }

    if (contacts.isEmpty) {
      contacts.add('Контактная информация пока не указана');
    }

    return _buildSection(
      icon: Icons.contact_phone,
      title: "Контактная информация",
      items: contacts,
    );
  }

  Widget _buildWebsiteSection() {
    final website = university?['website'];

    if (website == null || website.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: InkWell(
        onTap: () async {
          final url = website.toString().trim();

          final uri = Uri.tryParse(
            url.startsWith('http') ? url : 'https://$url',
          );

          if (uri == null) return;

          final canOpen = await canLaunchUrl(uri);
          
          print("===== OPEN WEBSITE =====");
          print("URL: $uri");
          print("CAN OPEN: $canOpen");
          print("========================");

          if (canOpen) {
            final launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );

           print("LAUNCHED: $launched");
          }
        },
        child: Row(
          children: [
            const Icon(
              Icons.language,
              color: Colors.white,
              size: 28,
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Text(
                "Официальный сайт университета",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Icon(
              Icons.open_in_new,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      showBackButton: true,
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUniversityCard(),

                    const SizedBox(height: 35),

                    _buildContactSection(),

                    const SizedBox(height: 20),

                    _buildWebsiteSection(),
                    
                    const SizedBox(height: 20),

                    if (_linksLoading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                    
                    else ...[
                      _buildSection(
                        icon: Icons.flash_on,
                        title: "Быстрый доступ",
                        items: _universityLinks.isEmpty
                            ? [
                                "Здесь пока нет сохранённых ссылок",
                              ]
                            : _universityLinks
                                .map((link) => link.title)
                                .toList(),
                        onLinkTap: _universityLinks.isEmpty
                         ? null
                          : (title) {
                              final link = _universityLinks.firstWhere(
                                (link) => link.title == title,
                              );

                              return _openLink(link.url);
                          },
                      ),
                      
                      const SizedBox(height: 10),
                      
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _showAddUniversityLinkDialog,
                          icon: const Icon(Icons.add),
                          label: const Text("Добавить ссылку"),
                        ),
                      ),
                    ],

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
     Future<void> Function(String url)? onLinkTap,
  }) {
    final bool isExpandable = items.length > 3;

    return _ExpandableSection(
      icon: icon,
      title: title,
      items: items,
      isExpandable: isExpandable,
      onLinkTap: onLinkTap,
    );
  }
}

/// 🔥 ОТДЕЛЬНЫЙ ЧИСТЫЙ STATEFUL WIDGET
class _ExpandableSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final bool isExpandable;
  final Future<void> Function(String url)? onLinkTap;

  const _ExpandableSection({
    required this.icon,
    required this.title,
    required this.items,
    required this.isExpandable,
    this.onLinkTap,
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
              children: widget.items.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    onTap: widget.onLinkTap != null
                    ? () => widget.onLinkTap!(e)
                    : null,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "• $e",
                        style: const TextStyle(color: Colors.white70),
                      ),
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