class NewsArticle {
  final String id;
  final String title;
  final String description;
  final String content;
  final String url;
  final String image;
  final DateTime publishedAt;
  final String sourceName;
  final String sourceUrl;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.url,
    required this.image,
    required this.publishedAt,
    required this.sourceName,
    required this.sourceUrl,
  });

  factory NewsArticle.fromMap(Map<String, dynamic> map) {
    final source = map['source'] ?? {};

    return NewsArticle(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      url: map['url'] ?? '',
      image: map['image'] ?? '',
      publishedAt: DateTime.parse(map['publishedAt']),
      sourceName: source['name'] ?? '',
      sourceUrl: source['url'] ?? '',
    );
  }
}