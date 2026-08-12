import 'package:url_launcher/url_launcher.dart';

class MapService {
  static Future<void> openCityMap({String? city}) async {
    final safeCity = (city == null || city.trim().isEmpty)
        ? "Москва"
        : city.trim();

    final isRussia = _isRussianCity(safeCity);

    final encodedCity = Uri.encodeComponent(safeCity);

    final url = isRussia
        ? Uri.parse("https://yandex.ru/maps/?text=$encodedCity")
        : Uri.parse("https://www.google.com/maps/search/$encodedCity");

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  }

  static bool _isRussianCity(String city) {
    final c = city.toLowerCase();

    const russianCities = [
      "москва",
      "moscow",
      "санкт-петербург",
      "spb",
      "питер",
      "kazan",
      "казань",
      "novosibirsk",
    ];

    return russianCities.any((e) => c.contains(e));
  }
}