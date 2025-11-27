import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/data/isar_service.dart';
import '../models/exam.dart';

part 'exam_repository.g.dart';

@Riverpod(keepAlive: true)
ExamRepository examRepository(ExamRepositoryRef ref) {
  final isarService = ref.watch(isarServiceProvider);
  return ExamRepository(isarService);
}

class ExamRepository {
  final IsarService _isarService;

  ExamRepository(this._isarService);

  Future<List<Exam>> getAllExams() async {
    return await _isarService.db.exams.where().findAll();
  }

  Future<void> addExam(Exam exam) async {
    await _isarService.db.writeTxn(() async {
      await _isarService.db.exams.put(exam);
    });
  }

  Future<void> deleteExam(Id id) async {
    await _isarService.db.writeTxn(() async {
      await _isarService.db.exams.delete(id);
    });
  }
}
