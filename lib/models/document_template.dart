import 'document_field.dart';


class DocumentTemplate {
  final String id;
  final String title;
  final List<DocumentField> fields;

  const DocumentTemplate({
    required this.id,
    required this.title,
    required this.fields,
  });
}