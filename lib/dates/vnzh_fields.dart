import 'package:intereasever2/models/document_field.dart';

const vnzhFields = [

  DocumentField(
    key: "name",
    title: "Имя",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "surname",
    title: "Фамилия",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "nameLatin",
    title: "Имя на латинице",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "surnameLatin",
    title: "Фамилия на латинице",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "middleName",
    title: "Отчество (если есть)",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "birthCity",
    title: "Город рождения",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "gender",
    title: "Пол",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "birthDate",
    title: "Дата рождения",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "passportSeria",
    title: "Серия паспорта (если есть)",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "passportNumber",
    title: "Номер паспорта",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "passportDate",
    title: "Дата выдачи",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "passportIssue",
    title: "Кем выдан",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "country",
    title: "Страна",
    source: FieldSource.profile,
  ),

  DocumentField(
    key: "maritalStatus",
    title: "Семейное положение",
    source: FieldSource.profile,
  ),

];