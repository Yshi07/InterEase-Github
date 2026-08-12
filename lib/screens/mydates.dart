import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:intereasever2/dates/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intereasever2/dates/edit_profile.dart';
import 'package:intereasever2/dates/service_documents.dart';


class MyDates extends StatefulWidget {
  const MyDates({super.key});
  
  @override
  State<MyDates> createState() => _MyDatesState();
}

class _MyDatesState extends State<MyDates> {
  UserProfile? user;
  bool isLoading = true;
  final supabase = Supabase.instance.client;

  Future<Map<String, bool>> loadDocumentsStatus() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return {};
    
    
    final data = await supabase
        .from('documents')
        .select('document_type')
        .eq('user_id', authUser.id);
        
    final Map<String, bool> status = {
      'passport': false,
      'visa': false,
      'card': false,
      'medicine': false,
      'certificate': false,
    };
    
    
    for (final item in data) {
      final type = item['document_type'];
      status[type] = true;
    }
    
    return status;
  }

  Map<String, bool> docStatus = {};
  
  @override
  void initState() {
    super.initState();
    loadProfile();
  }
  
  Future<void> fetchDocs() async {
    final result = await loadDocumentsStatus();
    if (!mounted) return;
    setState(() {
      docStatus = result;
    });
  }

  Future<void> loadProfile() async {

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', supabase.auth.currentUser!.id)
        .single();

    setState(() {
      user = UserProfile.fromMap(data);
      isLoading = false;
    });
    await fetchDocs();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final u = user!; // чтобы не писать ? постоянно

    return AppLayout(
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// Аватар + имя
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage(
                    "assets/images/avatar.jpg",
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Text(
                    u.firstName,
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Карточка данных
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white54,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _infoRow("Фамилия", u.lastName),
                  _infoRow("Имя", u.firstName),
                  _infoRow("Дата рождения", u.formattedBirthDate),
                  _infoRow("Страна", u.country),
                  _infoRow("Родной язык", u.language),

                  const SizedBox(height: 15),

                  _infoRow("Вуз", u.university),
                  _infoRow("Направление", u.specialization),
                  _infoRow("Год поступления", u.admissionYear.toString()),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 220,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfile(user: u),
                    ),
                  );

                   setState(() { // перезагрузить данные
                  });
                },
                icon: const Icon(Icons.edit),
                label: const Text("Редактировать"),
              ),
            ),

             const SizedBox(height: 30),

            /// Документы
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Документы",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                DocumentCard(
                  title: "Паспорт",
                  width: 90,
                  hasFile: docStatus['passport'] ?? false,
                  onTap: () async {
                    if (docStatus['passport'] == true) {
                      final path = await getFilePath('passport');
                      if (path != null) {
                        await DocumentService.openDocument(path);
                      }
                    } else {
                      await DocumentService.uploadDocument('passport');
                      fetchDocs();
                      }
                  },
                  
                  onDelete: () async {
                    final path = await getFilePath('passport');
                    if (path != null) {
                      await DocumentService.deleteDocument(path, 'passport');
                      fetchDocs();
                    }
                  },
                  
                ),
                DocumentCard(
                  title: "Виза",
                  width: 90,
                  hasFile: docStatus['visa'] ?? false,
                  onTap: () async {
                    if (docStatus['visa'] == true) {
                      final path = await getFilePath('visa');
                      if (path != null) {
                        await DocumentService.openDocument(path);
                      }
                    } else {
                      await DocumentService.uploadDocument('visa');
                      fetchDocs();
                      }
                  },
                  
                  onDelete: () async {
                    final path = await getFilePath('visa');
                    if (path != null) {
                      await DocumentService.deleteDocument(path, 'visa');
                      fetchDocs();
                    }
                  },
                ),
                DocumentCard(
                  title: "Миграционная\nкарта",
                  width: 105,
                  hasFile: docStatus['card'] ?? false,
                  onTap: () async {
                    if (docStatus['card'] == true) {
                      final path = await getFilePath('card');
                      if (path != null) {
                        await DocumentService.openDocument(path);
                      }
                    } else {
                      await DocumentService.uploadDocument('card');
                      fetchDocs();
                      }
                  },
                  
                  onDelete: () async {
                    final path = await getFilePath('card');
                    if (path != null) {
                      await DocumentService.deleteDocument(path, 'card');
                      fetchDocs();
                    }
                  },
                ),
                DocumentCard(
                  title: "Медицинские\nанализы",
                  width: 105,
                  hasFile: docStatus['medicine'] ?? false,
                  onTap: () async {
                    if (docStatus['medicine'] == true) {
                      final path = await getFilePath('medicine');
                      if (path != null) {
                        await DocumentService.openDocument(path);
                      }
                    } else {
                      await DocumentService.uploadDocument('medicine');
                      fetchDocs();
                      }
                  },
                  
                  onDelete: () async {
                    final path = await getFilePath('medicine');
                    if (path != null) {
                      await DocumentService.deleteDocument(path, 'medicine');
                      fetchDocs();
                    }
                  },
                ),
                DocumentCard(
                  title: "Сертификат",
                  width: 90,
                  hasFile: docStatus['sertificate'] ?? false,
                  onTap: () async {
                    if (docStatus['sertificate'] == true) {
                      final path = await getFilePath('sertificate');
                      if (path != null) {
                        await DocumentService.openDocument(path);
                      }
                    } else {
                      await DocumentService.uploadDocument('sertificate');
                      fetchDocs();
                      }
                  },
                  
                  onDelete: () async {
                    final path = await getFilePath('sertificate');
                    if (path != null) {
                      await DocumentService.deleteDocument(path, 'sertificate');
                      fetchDocs();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        "$title: $value",
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
}


class DocumentCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;
  final bool hasFile;
  final double width;

  const DocumentCard({
    super.key,
    required this.title,
    required this.onTap,
    this.onOpen,
    this.onDelete,
    this.hasFile = false,
    this.width = 90,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            child: Container(
              width: width,
              height: 120,
              decoration: BoxDecoration(
                color: hasFile
                    ? Colors.green.withOpacity(0.25)
                    : Colors.white24,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: hasFile ? Colors.green : Colors.transparent,
                  width: 2,
                ),
                boxShadow: hasFile
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Icon(
                hasFile ? Icons.check_circle : Icons.description,
                color: hasFile ? Colors.greenAccent : Colors.white,
                size: 40,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 🔥 НАЗВАНИЕ + КНОПКА УДАЛЕНИЯ
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasFile ? Colors.greenAccent : Colors.white,
                    fontWeight:
                        hasFile ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),

              if (hasFile)
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

