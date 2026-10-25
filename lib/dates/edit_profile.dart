import 'package:flutter/material.dart';
import 'package:intereasever2/dates/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intereasever2/screens/university_search.dart';



class EditProfile extends StatefulWidget {
  final UserProfile user;

  const EditProfile({
    super.key,
    required this.user,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController lastNameController;
  late TextEditingController firstNameController;
  late TextEditingController countryController;
  late TextEditingController birthDateController;
  late TextEditingController languageController;
  late TextEditingController universityController;
  late TextEditingController specializationController;
  late TextEditingController admissionYearController;
  late TextEditingController cityController;

  Map<String, dynamic>? selectedUniversity;


  DateTime? parseCustomDate(String input) {
    try {
      final parts = input.split('-');
      
      if (parts.length != 3) return null;
      
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      
      return DateTime(year, month, day);
    } catch (e) {
      return null;
      }
  }

bool isValidDate(String input) {
  return parseCustomDate(input) != null;
}


  @override
  void initState() {
    super.initState();

    lastNameController =
        TextEditingController(text: widget.user.lastName);

    firstNameController =
        TextEditingController(text: widget.user.firstName);

    countryController =
        TextEditingController(text: widget.user.country);

    birthDateController = TextEditingController(
      text: widget.user.birthDate == null
          ? ''
          : "${widget.user.birthDate!.day.toString().padLeft(2, '0')}-"
            "${widget.user.birthDate!.month.toString().padLeft(2, '0')}-"
            "${widget.user.birthDate!.year}",
    );

    languageController =
        TextEditingController(text: widget.user.language);

    admissionYearController =
      TextEditingController(
        text: widget.user.admissionYear == 0
        ? ''
        : widget.user.admissionYear.toString(),
      );

    universityController =
        TextEditingController(text: widget.user.university);

    if (widget.user.universityId != null) {
      selectedUniversity = {
        'id': widget.user.universityId,
        'full_name': widget.user.university,
      };
    }

    cityController =
        TextEditingController(text: widget.user.city);

    specializationController =
        TextEditingController(text: widget.user.specialization);
  }

  Future<void> saveProfile() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    
    final birthText = birthDateController.text.trim();
    final parsedDate = birthText.isEmpty ? null : parseCustomDate(birthText);
    
    // ❌ защита от кривой даты
    
    if (birthText.isNotEmpty && parsedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Дата должна быть в формате дд-мм-гггг"),
        ),
      );
      return;
    }
    
    final admissionYear = int.tryParse(admissionYearController.text);
    
    await Supabase.instance.client.from('profiles').update({
      'name': firstNameController.text.trim(),
      'surname': lastNameController.text.trim(),
      'country': countryController.text.trim(),
      'birth_date': parsedDate?.toIso8601String(),
      'language': languageController.text.trim(),
      'university': universityController.text.trim(),
      'university_id': selectedUniversity?['id'],
      'specialization': specializationController.text.trim(),
      'russian_city': cityController.text.trim(),
      'admission_year': admissionYear,
      }).eq('id', userId);
      
      if (!mounted) return;
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактирование"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: "Фамилия",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: "Имя",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: "Страна",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: birthDateController,
              decoration: const InputDecoration(
                labelText: "Дата рождения",
                hintText: "дд-мм-гггг",
              ),
            ),

            const SizedBox(height: 20),

             TextField(
              controller: languageController,
              decoration: const InputDecoration(
                labelText: "Язык общения",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: "Город проживания",
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UniversitySearch(),
                  ),
                );
                
                if (result != null) {
                  final shortName =
                  (result['short_name'] ?? '').toString().split(',').first.trim();
                  
                  setState(() {
                    selectedUniversity = result;
                    universityController.text = shortName;
                  });
                }
              },
              
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Университет",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
                
                child: Text(
                  universityController.text.isEmpty
                  ? "Выберите университет"
                  : universityController.text,
                  style: TextStyle(
                    color: universityController.text.isEmpty
                    ? Colors.grey
                    : Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: specializationController,
              decoration: const InputDecoration(
                labelText: "Специальность",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: admissionYearController,
              decoration: const InputDecoration(
                labelText: "Год поступления",
              ),
            ),

            const SizedBox(height: 20),

            

            ElevatedButton(
              onPressed: saveProfile,
              child: const Text("Сохранить"),
            ),
          ],
        ),
      ),
    );
  }
}