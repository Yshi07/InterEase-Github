import 'package:flutter/material.dart';
import 'package:intereasever2/app_layout.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intereasever2/models/news_article.dart';
import 'package:intereasever2/services/news_api_service.dart';


class PageNews extends StatelessWidget {
  const PageNews({super.key});

  @override
  Widget build(BuildContext context) {
    final newsService = NewsApiService();

    return AppLayout(
      showBackButton: true,
      child: FutureBuilder<List<NewsArticle>>(
        future: newsService.getNews(),
        builder: (context, snapshot) {

          // Загрузка
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Ошибка
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Не удалось загрузить новости:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          // Новости
          final news = snapshot.data ?? [];

          if (news.isEmpty) {
            return const Center(
              child: Text(
                'Новостей пока нет',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: news.length,
            itemBuilder: (context, index) {

              final article = news[index];


              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    final uri = Uri.parse(article.url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (article.image.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          article.image,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              height: 180,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            article.description,
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            article.sourceName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}