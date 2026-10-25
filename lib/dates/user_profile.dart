import 'package:intl/intl.dart';

class UserProfile {
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final String country;
  final String language;
  final String university;
  final int? universityId;
  final String specialization;
  final String city;
  final int admissionYear;

  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.country,
    required this.language,
    required this.university,
    required this.universityId,
    required this.specialization,
    required this.city,
    required this.admissionYear,
  });

  String get formattedBirthDate {
    if (birthDate == null) return '';

    return "${birthDate!.day.toString().padLeft(2, '0')}-"
        "${birthDate!.month.toString().padLeft(2, '0')}-"
        "${birthDate!.year}";
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['name'] ?? '',
      lastName: map['surname'] ?? '',
      birthDate: map['birth_date'] != null
          ? DateTime.parse(map['birth_date'])
          : null,
      country: map['country'] ?? '',
      language: map['language'] ?? '',
      university: map['university'] ?? '',
      universityId: map['university_id'],
      specialization: map['specialization'] ?? '',
      city: map['russian_city'] ?? '',
      admissionYear: map['admission_year'] ?? 0,
    );
  }
}