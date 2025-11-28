import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:study_companion/core/data/isar_service.dart';
import 'package:study_companion/features/learning/data/models/saved_exam.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExamHistoryScreen extends ConsumerStatefulWidget {
  const ExamHistoryScreen({super.key});

  @override
  ConsumerState<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends ConsumerState<ExamHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz History'),
      ),
      body: FutureBuilder<List<SavedExam>>(
        future: ref.read(isarServiceProvider).getSavedExams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final exams = snapshot.data ?? [];
          
          if (exams.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu, size: 64, color: Colors.grey),
                  Gap(16),
                  Text('No quizzes taken yet.'),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getScoreColor(exam.score, exam.totalQuestions),
                    child: Text(
                      '${(exam.score / exam.totalQuestions * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(exam.topic.isNotEmpty ? exam.topic : 'Quiz'),
                  subtitle: Text(DateFormat.yMMMd().add_jm().format(exam.date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(exam.id),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatItem(label: 'Score', value: '${exam.score}/${exam.totalQuestions}'),
                              _StatItem(label: 'Language', value: exam.language),
                            ],
                          ),
                          const Gap(16),
                          FilledButton.icon(
                            onPressed: () => _generatePdf(exam),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Export PDF'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(isarServiceProvider).deleteExam(id);
      setState(() {}); // Refresh list
    }
  }

  Color _getScoreColor(int score, int total) {
    final percentage = score / total;
    if (percentage >= 0.8) return Colors.green;
    if (percentage >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Future<void> _generatePdf(SavedExam exam) async {
    final pdf = pw.Document();
    // Load Noto Serif Bengali for better rendering
    final fontRegular = await PdfGoogleFonts.notoSerifBengaliRegular();
    final fontBold = await PdfGoogleFonts.notoSerifBengaliBold();

    pdf.addPage(
      pw.MultiPage(
        // Apply theme globally to ensure all text uses the correct font
        theme: pw.ThemeData.withFont(
          base: fontRegular,
          bold: fontBold,
        ),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Exam Result', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text(DateFormat.yMMMd().format(exam.date)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Topic: ${exam.topic}'), // Now uses theme font
                pw.Text('Score: ${exam.score}/${exam.totalQuestions}'),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 20),
            ...exam.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final q = entry.value;
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Q${index + 1}: ${q.question}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 5),
                  ...q.options.asMap().entries.map((optEntry) {
                    final optIndex = optEntry.key;
                    final opt = optEntry.value;
                    final isCorrect = optIndex == q.correctIndex;
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 10, bottom: 2),
                      child: pw.Text(
                        '${String.fromCharCode(65 + optIndex)}. $opt ${isCorrect ? '(Correct)' : ''}',
                        style: pw.TextStyle(
                          color: isCorrect ? PdfColors.green : PdfColors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  pw.SizedBox(height: 5),
                  pw.Text('Explanation: ${q.explanation}', style: pw.TextStyle(color: PdfColors.grey700)),
                  pw.SizedBox(height: 15),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Gap(4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
