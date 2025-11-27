import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  late String name;
  late String grade; // Class
  String? schoolName;
  late String email;

  DateTime createdAt = DateTime.now();
}
