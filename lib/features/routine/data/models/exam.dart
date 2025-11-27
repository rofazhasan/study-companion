import 'package:isar/isar.dart';

part 'exam.g.dart';

@collection
class Exam {
  Id id = Isar.autoIncrement;

  late String name; // e.g., "Semester 1", "Half Yearly"

  List<ExamSubject> subjects = [];
}

@embedded
class ExamSubject {
  late String subjectName;
  
  late DateTime dateTime;
  
  int durationMinutes = 180; // Default 3 hours
}
