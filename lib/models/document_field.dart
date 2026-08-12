enum FieldSource {
  profile,
  saved,
  document,
}


class DocumentField {
  final String key;
  final String title;
  final FieldSource source;
  final bool required;

  const DocumentField({
    required this.key,
    required this.title,
    required this.source,
    this.required = false,
  });
}