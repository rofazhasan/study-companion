import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/subject_provider.dart';
import '../providers/routine_ai_provider.dart';
import '../../../../core/providers/connectivity_provider.dart';

class AIPlannerDialog extends ConsumerStatefulWidget {
  final DateTime date;

  const AIPlannerDialog({super.key, required this.date});

  @override
  ConsumerState<AIPlannerDialog> createState() => _AIPlannerDialogState();
}

class _AIPlannerDialogState extends ConsumerState<AIPlannerDialog> {
  final _selectedSubjects = <String>{};
  final _customSubjects = <String>{};
  String _mood = 'Energetic';
  double _totalHours = 4;

  final _moods = ['Energetic', 'Normal', 'Tired', 'Stressed', 'Motivated'];

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final aiState = ref.watch(routineAIProvider);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.purple),
          Gap(8),
          Text('AI Day Planner'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let AI optimize your schedule based on your goals and energy.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(16),
            
            // Subjects
            const Text('What do you want to study?', style: TextStyle(fontWeight: FontWeight.bold)),
            const Gap(8),
            subjectsAsync.when(
              data: (subjects) {
                final allSubjects = {...subjects.map((s) => s.name), ..._customSubjects};
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (allSubjects.isEmpty) 
                      const Text('No subjects found. Add one below!'),
                      
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...allSubjects.map((subject) {
                          final isSelected = _selectedSubjects.contains(subject);
                          return FilterChip(
                            label: Text(subject),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedSubjects.add(subject);
                                } else {
                                  _selectedSubjects.remove(subject);
                                }
                              });
                            },
                          );
                        }),
                        ActionChip(
                          avatar: const Icon(Icons.add, size: 18),
                          label: const Text('Add Custom'),
                          onPressed: _showAddSubjectDialog,
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading subjects'),
            ),
            const Gap(16),

            // Mood
            const Text('How are you feeling?', style: TextStyle(fontWeight: FontWeight.bold)),
            const Gap(8),
            DropdownButtonFormField<String>(
              value: _mood,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _moods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _mood = val!),
            ),
            const Gap(16),

            // Time
            Text('Total Study Time: ${_totalHours.round()} hours', style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _totalHours,
              min: 1,
              max: 12,
              divisions: 11,
              label: '${_totalHours.round()}h',
              onChanged: (val) => setState(() => _totalHours = val),
            ),
            
            if (aiState.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Gap(8),
                    Text('Generating your perfect schedule...'),
                  ],
                ),
              ),
            
            if (aiState.hasError)
               Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  'Error: ${aiState.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (!aiState.isLoading) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              final connectivityAsync = ref.watch(connectivityNotifierProvider);
              return connectivityAsync.when(
                data: (isOnline) => FilledButton.icon(
                  onPressed: !isOnline
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This feature requires internet connection'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      : (_selectedSubjects.isEmpty ? null : _generateSchedule),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate'),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => FilledButton.icon(
                  onPressed: _selectedSubjects.isEmpty ? null : _generateSchedule,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate'),
                ),
              );
            },
          ),
        ],
      ],
    );
    }

  void _showAddSubjectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Subject'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Subject Name',
            hintText: 'e.g., Quantum Physics',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _customSubjects.add(name);
                  _selectedSubjects.add(name);
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }


  Future<void> _generateSchedule() async {
    await ref.read(routineAIProvider.notifier).generateSchedule(
      subjects: _selectedSubjects.toList(),
      mood: _mood,
      date: widget.date,
      totalHours: _totalHours.round(),
    );
    
    if (mounted && !ref.read(routineAIProvider).hasError) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule generated successfully!')),
      );
    }
  }
}
