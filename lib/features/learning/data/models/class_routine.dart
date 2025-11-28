import 'package:isar/isar.dart';

part 'class_routine.g.dart';

@collection
class ClassRoutine {
  Id id = Isar.autoIncrement;

  late String subjectName;
  late DateTime startTime;
  late DateTime endTime;
  
  // 1 = Monday, 7 = Sunday (ISO 8601)
  late int dayOfWeek;
  
  late String classroom;
  late String institution;
  
  // Color value (int)
  late int color;
}
