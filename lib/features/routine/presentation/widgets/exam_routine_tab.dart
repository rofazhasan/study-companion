import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/exam.dart';
import '../../data/repositories/exam_repository.dart';
import 'add_exam_dialog.dart';

class ExamRoutineTab extends ConsumerStatefulWidget {
  const ExamRoutineTab({super.key});

  @override
  ConsumerState<ExamRoutineTab> createState() => _ExamRoutineTabState();
}

class _ExamRoutineTabState extends ConsumerState<ExamRoutineTab> {
  String _filter = 'All'; // All, Today, Month

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Exam>>(
      future: ref.watch(examRepositoryProvider).getAllExams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final exams = snapshot.data ?? [];
        if (exams.isEmpty) {
          return _buildEmptyState(context);
        }

        final filteredExams = _filterExams(exams);
        _sortExams(filteredExams);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const Gap(8),
                    _buildFilterChip('Today'),
                    const Gap(8),
                    _buildFilterChip('This Month'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      tooltip: 'Export Routine',
                      onPressed: () => _exportRoutine(filteredExams),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredExams.length,
                  itemBuilder: (context, index) {
                    final exam = filteredExams[index];
                    return _buildExamCard(context, exam);
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AddExamDialog(),
            ).then((_) => setState(() {})),
            icon: const Icon(Icons.add),
            label: const Text('Add Exam'),
            heroTag: 'add_exam_fab', // Unique tag to avoid conflict
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment_late, size: 64, color: Colors.grey),
          const Gap(16),
          Text(
            'No exams scheduled',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(8),
          FilledButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const AddExamDialog(),
            ).then((_) => setState(() {})),
            icon: const Icon(Icons.add),
            label: const Text('Add Exam Routine'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _filter == label,
      onSelected: (selected) {
        if (selected) setState(() => _filter = label);
      },
    );
  }

  List<Exam> _filterExams(List<Exam> exams) {
    if (_filter == 'All') return exams;
    
    final now = DateTime.now();
    return exams.where((exam) {
      return exam.subjects.any((subject) {
        if (_filter == 'Today') {
          return subject.dateTime.year == now.year &&
                 subject.dateTime.month == now.month &&
                 subject.dateTime.day == now.day;
        } else if (_filter == 'This Month') {
          return subject.dateTime.year == now.year &&
                 subject.dateTime.month == now.month;
        }
        return true;
      });
    }).toList();
  }

  void _sortExams(List<Exam> exams) {
    // Sort by earliest subject date
    exams.sort((a, b) {
      final aDate = a.subjects.map((e) => e.dateTime).reduce((a, b) => a.isBefore(b) ? a : b);
      final bDate = b.subjects.map((e) => e.dateTime).reduce((a, b) => a.isBefore(b) ? a : b);
      return aDate.compareTo(bDate);
    });
  }

  Widget _buildExamCard(BuildContext context, Exam exam) {
    final now = DateTime.now();
    final isExamOver = exam.subjects.every((s) => s.dateTime.add(Duration(minutes: s.durationMinutes)).isBefore(now));
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isExamOver ? Colors.grey.withOpacity(0.2) : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        childrenPadding: const EdgeInsets.only(bottom: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isExamOver ? Colors.grey.withOpacity(0.1) : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.school_rounded,
                color: isExamOver ? Colors.grey : Theme.of(context).colorScheme.primary,
              ),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      if (isExamOver)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('COMPLETED', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('UPCOMING', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      const Gap(8),
                      Text(
                        '${exam.subjects.length} Subjects',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8, left: 60), // Align with text
          child: Text(
            _getExamDateRange(exam),
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.blue),
              tooltip: 'Export this Exam',
              onPressed: () => _exportRoutine([exam]),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                 await ref.read(examRepositoryProvider).deleteExam(exam.id);
                 setState(() {});
              },
            ),
          ],
        ),
        children: exam.subjects.map((subject) {
          final isSubjectOver = subject.dateTime.add(Duration(minutes: subject.durationMinutes)).isBefore(now);
          return ListTile(
            leading: Icon(
              isSubjectOver ? Icons.check_circle : Icons.circle_outlined,
              color: isSubjectOver ? Colors.grey : Colors.blue,
            ),
            title: Text(
              subject.subjectName,
              style: TextStyle(
                decoration: isSubjectOver ? TextDecoration.lineThrough : null,
                color: isSubjectOver ? Colors.grey : null,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(DateFormat('EEEE, MMM d • h:mm a').format(subject.dateTime)),
            trailing: isSubjectOver 
              ? const Text('Finished', style: TextStyle(color: Colors.grey, fontSize: 12))
              : const Text('Available', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
          );
        }).toList(),
      ),
    );
  }

  String _getExamDateRange(Exam exam) {
    if (exam.subjects.isEmpty) return '';
    final dates = exam.subjects.map((e) => e.dateTime).toList()..sort();
    final start = dates.first;
    final end = dates.last;
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return DateFormat('MMM d').format(start);
    }
    return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
  }

  Future<void> _exportRoutine(List<Exam> exams) async {
    try {
      final pdf = pw.Document();
      final now = DateTime.now();

      for (final exam in exams) {
        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(40),
            footer: (context) {
              return pw.Column(
                children: [
                  pw.Divider(color: PdfColors.grey400),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Study Companion App', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                      pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500)),
                    ],
                  ),
                ],
              );
            },
            build: (context) => [
              // Professional Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('EXAM ROUTINE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.SizedBox(height: 4),
                      pw.Text(exam.name.toUpperCase(), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Generated on', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                      pw.Text(DateFormat('MMMM d, yyyy').format(now), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.Divider(color: PdfColors.blue900, thickness: 2),
              pw.SizedBox(height: 20),
              
              // Stats Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildPdfStat('Total Subjects', '${exam.subjects.length}'),
                  _buildPdfStat('Start Date', _getStartDate(exam)),
                  _buildPdfStat('End Date', _getEndDate(exam)),
                ],
              ),
              pw.SizedBox(height: 30),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3), // Subject
                  1: const pw.FlexColumnWidth(2.5), // Date
                  2: const pw.FlexColumnWidth(1.5), // Time
                  3: const pw.FlexColumnWidth(1.5), // Duration
                  4: const pw.FlexColumnWidth(1.5), // Status
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      _buildPdfHeaderCell('SUBJECT'),
                      _buildPdfHeaderCell('DATE'),
                      _buildPdfHeaderCell('TIME'),
                      _buildPdfHeaderCell('DURATION'),
                      _buildPdfHeaderCell('STATUS'),
                    ],
                  ),
                  ...exam.subjects.map((subject) {
                    final isOver = subject.dateTime.add(Duration(minutes: subject.durationMinutes)).isBefore(now);
                    return pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200)),
                      ),
                      children: [
                        _buildPdfCell(subject.subjectName, isBold: true, align: pw.TextAlign.left),
                        _buildPdfCell(DateFormat('EEE, MMM d, yyyy').format(subject.dateTime)),
                        _buildPdfCell(DateFormat('h:mm a').format(subject.dateTime)),
                        _buildPdfCell('${subject.durationMinutes ~/ 60}h ${subject.durationMinutes % 60}m'),
                        _buildPdfCell(
                          isOver ? 'COMPLETED' : 'UPCOMING', 
                          color: isOver ? PdfColors.grey : PdfColors.green700,
                          isBold: true
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      }

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Exam_Routine_${DateFormat('yyyyMMdd').format(now)}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e')),
        );
      }
    }
  }

  pw.Widget _buildPdfStat(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  String _getStartDate(Exam exam) {
    if (exam.subjects.isEmpty) return '-';
    final dates = exam.subjects.map((e) => e.dateTime).toList()..sort();
    return DateFormat('MMM d').format(dates.first);
  }

  String _getEndDate(Exam exam) {
    if (exam.subjects.isEmpty) return '-';
    final dates = exam.subjects.map((e) => e.dateTime).toList()..sort();
    return DateFormat('MMM d').format(dates.last);
  }

  pw.Widget _buildPdfHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: pw.Center(
        child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.blue900)),
      ),
    );
  }

  pw.Widget _buildPdfCell(String text, {bool isBold = false, PdfColor color = PdfColors.black, pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: pw.Align(
        alignment: align == pw.TextAlign.left ? pw.Alignment.centerLeft : pw.Alignment.center,
        child: pw.Text(
          text, 
          style: pw.TextStyle(
            fontSize: 9, 
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      ),
    );
  }
}
