class SavedLink {
  final String id;
  final String userId;
  final String title;
  final String url;
  final String type;
  final String section;
  final DateTime createdAt;

  const SavedLink({
    required this.id,
    required this.userId,
    required this.title,
    required this.url,
    required this.type,
    required this.section,
    required this.createdAt,
  });

  factory SavedLink.fromMap(Map<String, dynamic> map) {
    return SavedLink(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      type: map['type'] as String,
      section: map['section'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'url': url,
      'type': type,
      'section': section,
      'created_at': createdAt.toIso8601String(),
    };
  }
}