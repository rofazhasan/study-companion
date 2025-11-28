import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:study_companion/core/data/isar_service.dart';
import 'package:study_companion/features/learning/data/models/class_routine.dart';

class ClassRoutineScreen extends ConsumerStatefulWidget {
  const ClassRoutineScreen({super.key});

  @override
  ConsumerState<ClassRoutineScreen> createState() => _ClassRoutineScreenState();
}

class _ClassRoutineScreenState extends ConsumerState<ClassRoutineScreen> {
  int _selectedDay = DateTime.now().weekday; // 1 = Mon, 7 = Sun

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isar = ref.watch(isarServiceProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildDaySelector(theme),
              Expanded(
                child: StreamBuilder<List<ClassRoutine>>(
                  stream: isar.watchClassRoutinesForDay(_selectedDay),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final classes = snapshot.data ?? [];

                    if (classes.isEmpty) {
                      return _buildEmptyState(theme);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: classes.length,
                      itemBuilder: (context, index) {
                        final routine = classes[index];
                        return _buildClassCard(context, routine);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClassDialog(),
        label: const Text('Add Class'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Class Routine',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance back button
        ],
      ),
    );
  }

  Widget _buildDaySelector(ThemeData theme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      height: 70, // Slightly taller to accommodate padding
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(7, (index) {
          final dayIndex = index + 1;
          final isSelected = dayIndex == _selectedDay;
          final isToday = DateTime.now().weekday == dayIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDay = dayIndex),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : (isToday ? theme.colorScheme.primaryContainer : theme.colorScheme.surface),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        color: isSelected 
                            ? theme.colorScheme.onPrimary 
                            : theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // Smaller font for small screens
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          const Gap(16),
          Text(
            'No classes scheduled',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Gap(8),
          Text(
            'Enjoy your free time!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }



  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  void _showAddClassDialog({ClassRoutine? routineToEdit}) {
    final formKey = GlobalKey<FormState>();
    String subject = routineToEdit?.subjectName ?? '';
    String classroom = routineToEdit?.classroom ?? '';
    String institution = routineToEdit?.institution ?? '';
    
    TimeOfDay startTime = routineToEdit != null 
        ? TimeOfDay.fromDateTime(routineToEdit.startTime) 
        : const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = routineToEdit != null 
        ? TimeOfDay.fromDateTime(routineToEdit.endTime) 
        : const TimeOfDay(hour: 10, minute: 0);
    int selectedColor = routineToEdit?.color ?? Colors.blue.toARGB32();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(routineToEdit == null ? 'Add Class' : 'Edit Class'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: subject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        prefixIcon: Icon(Icons.book),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                      onSaved: (v) => subject = v ?? '',
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(context: context, initialTime: startTime);
                              if (time != null) setState(() => startTime = time);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Time',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(startTime.format(context)),
                            ),
                          ),
                        ),
                        const Gap(8),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(context: context, initialTime: endTime);
                              if (time != null) setState(() => endTime = time);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Time',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    TextFormField(
                      initialValue: classroom,
                      decoration: const InputDecoration(
                        labelText: 'Classroom',
                        prefixIcon: Icon(Icons.room),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (v) => classroom = v ?? '',
                    ),
                    const Gap(16),
                    TextFormField(
                      initialValue: institution,
                      decoration: const InputDecoration(
                        labelText: 'Institution',
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (v) => institution = v ?? '',
                    ),
                    const Gap(16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo
                        ].map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedColor = c.toARGB32()),
                            child: CircleAvatar(
                              backgroundColor: c,
                              radius: 16,
                              child: selectedColor == c.toARGB32() ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                            ),
                          ),
                        )).toList(),
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
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    
                    // Create DateTimes for comparison (using a dummy date)
                    final now = DateTime.now();
                    final start = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
                    final end = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

                    if (end.isBefore(start)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('End time must be after start time')),
                      );
                      return;
                    }

                    // Check for conflicts
                    final routines = await ref.read(isarServiceProvider).getClassRoutinesForDay(_selectedDay);
                    bool hasConflict = false;
                    for (var r in routines) {
                      if (routineToEdit != null && r.id == routineToEdit.id) continue; // Skip self

                      final rStart = DateTime(now.year, now.month, now.day, r.startTime.hour, r.startTime.minute);
                      final rEnd = DateTime(now.year, now.month, now.day, r.endTime.hour, r.endTime.minute);

                      if (start.isBefore(rEnd) && end.isAfter(rStart)) {
                        hasConflict = true;
                        break;
                      }
                    }

                    if (hasConflict) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conflict detected! Another class exists at this time.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    final routine = ClassRoutine()
                      ..subjectName = subject
                      ..startTime = start
                      ..endTime = end
                      ..dayOfWeek = _selectedDay
                      ..classroom = classroom
                      ..institution = institution
                      ..color = selectedColor;
                    
                    if (routineToEdit != null) {
                      routine.id = routineToEdit.id;
                    }

                    await ref.read(isarServiceProvider).saveClassRoutine(routine);
                    if (context.mounted) Navigator.pop(context);
                    setState(() {}); // Refresh list
                  }
                },
                child: Text(routineToEdit == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassRoutine routine) {
    final theme = Theme.of(context);
    final color = Color(routine.color);
    final duration = routine.endTime.difference(routine.startTime);
    final height = (duration.inMinutes / 60.0) * 100.0; // 100px per hour

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: height < 80 ? 80 : height, // Minimum height
      child: InkWell(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddClassDialog(routineToEdit: routine);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(isarServiceProvider).deleteClassRoutine(routine.id);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            border: Border(left: BorderSide(color: color, width: 4)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatTime(routine.startTime)} - ${_formatTime(routine.endTime)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    '${duration.inMinutes} min',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      routine.subjectName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (routine.classroom.isNotEmpty || routine.institution.isNotEmpty) ...[
                      const Gap(4),
                      Row(
                        children: [
                          if (routine.classroom.isNotEmpty) ...[
                            Icon(Icons.room, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            const Gap(4),
                            Text(
                              routine.classroom,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const Gap(12),
                          ],
                          if (routine.institution.isNotEmpty) ...[
                            Icon(Icons.school, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                            const Gap(4),
                            Expanded(
                              child: Text(
                                routine.institution,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
