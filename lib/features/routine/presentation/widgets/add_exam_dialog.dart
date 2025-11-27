import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../../data/models/exam.dart';
import '../../data/repositories/exam_repository.dart';
import '../../../../core/services/notification_service.dart';

class AddExamDialog extends ConsumerStatefulWidget {
  const AddExamDialog({super.key});

  @override
  ConsumerState<AddExamDialog> createState() => _AddExamDialogState();
}

class _AddExamDialogState extends ConsumerState<AddExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<ExamSubject> _subjects = [];

  void _addSubject() {
    setState(() {
      _subjects.add(ExamSubject()
        ..subjectName = ''
        ..dateTime = DateTime.now().add(const Duration(days: 1))
        ..durationMinutes = 180);
    });
  }

  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
  }

  Future<void> _selectDateTime(int index) async {
    final current = _subjects[index].dateTime;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(current),
      );
      
      if (time != null) {
        setState(() {
          _subjects[index].dateTime = DateTime(
            date.year, date.month, date.day, time.hour, time.minute
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Exam Routine'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exam Name (e.g., Semester 1)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subjects', style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add_circle, color: Colors.blue),
                    tooltip: 'Add Subject',
                  ),
                ],
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: subject.subjectName,
                                    decoration: const InputDecoration(labelText: 'Subject Name'),
                                    onChanged: (v) => subject.subjectName = v,
                                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeSubject(index),
                                ),
                              ],
                            ),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(DateFormat('MMM d, y - h:mm a').format(subject.dateTime)),
                              trailing: const Icon(Icons.calendar_today, size: 16),
                              onTap: () => _selectDateTime(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (_formKey.currentState!.validate() && _subjects.isNotEmpty) {
              try {
                final exam = Exam()
                  ..name = _nameController.text
                  ..subjects = _subjects;
                
                await ref.read(examRepositoryProvider).addExam(exam);
                
                // Schedule alarms
                final notificationService = ref.read(notificationServiceProvider);
                for (final subject in _subjects) {
                  // Alarm 1 day before
                  final alarmTime = subject.dateTime.subtract(const Duration(days: 1));
                  if (alarmTime.isAfter(DateTime.now())) {
                    await notificationService.scheduleExamAlarm(
                      title: 'Upcoming Exam: ${subject.subjectName}',
                      body: 'Tomorrow at ${DateFormat('h:mm a').format(subject.dateTime)}. Get ready!',
                      scheduledDate: alarmTime,
                    );
                  }
                }
                
                if (mounted) Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving exam: $e')),
                  );
                }
              }
            } else if (_subjects.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add at least one subject')),
              );
            }
          },
          child: const Text('Save Routine'),
        ),
      ],
    );
  }
}
