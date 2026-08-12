import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final supabase = Supabase.instance.client;

class DocumentService {

    static Future<void> uploadDocument(String docType) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'png'],
  );

  if (result == null) return;

  final file = File(result.files.single.path!);

  final user = supabase.auth.currentUser;
  if (user == null) return;

  final fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}';

  final path = '${user.id}/$fileName';

  // 1. загрузка в Storage
  await supabase.storage
      .from('documents')
      .upload(path, file);

  // 2. получаем public URL (или path используем как есть)
  final filePath = path;

  // 3. сохраняем в таблицу
  await supabase.from('documents').insert({
    'user_id': user.id,
    'document_type': docType,
    'file_path': filePath,
  });
}


// 👁 открыть файл

static Future<void> openDocument(String filePath) async {
  final signedUrl = await supabase.storage
      .from('documents')
      .createSignedUrl(filePath, 60);

  final uri = Uri.parse(signedUrl);

  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

  // 🗑 удалить файл
  static Future<void> deleteDocument(
      String filePath,
      String docType,
  ) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.storage
        .from('documents')
        .remove([filePath]);

    await supabase
        .from('documents')
        .delete()
        .eq('user_id', user.id)
        .eq('file_path', filePath)
        .eq('document_type', docType);
  }
}

Future<String?> getFilePath(String docType) async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final data = await supabase
      .from('documents')
      .select('file_path')
      .eq('user_id', user.id)
      .eq('document_type', docType)
      .maybeSingle();

  return data?['file_path'];
}