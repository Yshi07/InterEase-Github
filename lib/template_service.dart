import 'dart:io';
import 'dart:typed_data';
import 'package:cleartec_docx_template/cleartec_docx_template.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_selector/file_selector.dart';


class TemplateService {

  Future<File> generateDocument({
    required String templateName,
    required Map<String, String> values,
  }) async {

    // Подготовка дополнительных полей
    _prepareValues(values);


    // Загружаем нужный Word шаблон
    final ByteData data = await rootBundle.load(
      'assets/templates/$templateName.docx',
    );

    final Uint8List bytes = Uint8List.fromList(
      data.buffer.asUint8List(),
    );


    final docx = await DocxTemplate.fromBytes(bytes);


    print('==============================');
    print('Шаблон: $templateName');
    print('Переданные значения:');
    print(values);
    print('Найденные теги:');
    print(docx.getTags());
    print('==============================');


    // Формируем контент для Word
    final content = Content();
    
    for (final entry in values.entries) {
      content.add(
        TextContent(
          entry.key,
          entry.value.isEmpty ? " " : entry.value,
        ),
      );
    }


    // Генерируем документ
    print("Готовим контент:");
    print(values.keys);
    print("Теги контента:");
    for (final item in values.entries) {
    print("${item.key} = ${item.value}");
}
    final generatedBytes = await docx.generate(content);


    if (generatedBytes == null) {
      throw Exception("Не удалось создать документ");
    }


    // Папка приложения

    final directory = await getApplicationDocumentsDirectory();
    
    final file = File(
      '${directory.path}/$templateName.docx',
    );
    
    await file.writeAsBytes(generatedBytes);
    
    print("Документ создан:${await file.exists()}");
    print(file.path);
    print("Размер: ${await file.length()}");

    return file;

  }


  void _prepareValues(Map<String, String> values) {


    // Университет используется дважды в документе
    if (values.containsKey("university")) {
      values["university2"] =
          values["university"] ?? "";
    }


    // Университет используется дважды в документе
    if (values.containsKey("country")) {
      values["country2"] =
          values["country"] ?? "";
    }


    // Разбиваем дату рождения
    final birthDate = values["birthDate"];


    if (birthDate != null &&
        birthDate.contains(".")) {

      final parts = birthDate.split(".");


      if (parts.length == 3) {

        values["birthDateDD"] = parts[0];

        values["birthDateMM"] = parts[1];

        values["birthDateYYYY"] = parts[2];
      }
    }
    values["birthDateDD"] ??= "";
    values["birthDateMM"] ??= "";
    values["birthDateYYYY"] ??= "";

        // Семейное положение для ВНЖ
    if (values.containsKey("maritalStatus")) {
      final maritalStatus =
          values["maritalStatus"]?.toLowerCase().trim();

      values["married"] = " ";
      values["single"] = " ";
      values["widow"] = " ";
      values["divorced"] = " ";

      switch (maritalStatus) {
        case "женат":
        case "замужем":
          values["married"] = "X";
          break;

        case "холост":
        case "не замужем":
          values["single"] = "X";
          break;

        case "вдовец":
        case "вдова":
          values["widow"] = "X";
          break;

        case "разведен":
        case "разведена":
          values["divorced"] = "X";
          break;
      }
    }

    // Пол
    if (values.containsKey("gender")) {
      final gender =
          values["gender"]?.toLowerCase().trim();

      values["f"] = " ";
      values["m"] = " ";

      switch (gender) {
        case "муж":
        case "м":
        case "мужчина":
          values["m"] = "X";
          break;

        case "жен":
        case "ж":
        case "женщина":
          values["f"] = "X";
          break;
      }
    }
  }
}