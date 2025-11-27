import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../data/models/mission.dart';
import '../providers/mission_provider.dart';

class MissionSelectionDialog extends ConsumerStatefulWidget {
  final DateTime date;
  final List<MissionItem> currentItems;

  const MissionSelectionDialog({
    super.key,
    required this.date,
    required this.currentItems,
  });

  @override
  ConsumerState<MissionSelectionDialog> createState() => _MissionSelectionDialogState();
}

class _MissionSelectionDialogState extends ConsumerState<MissionSelectionDialog> {
  late List<MissionItem> _selectedItems;
  
  final List<MissionItem> _availableMissions = [
    MissionItem()
      ..title = 'Complete 3 Study Blocks'
      ..xpReward = 50
      ..type = MissionType.studyBlocks
      ..target = 3
      ..isManual = false,
    MissionItem()
      ..title = 'Focus for 60 Minutes'
      ..xpReward = 40
      ..type = MissionType.focusTime
      ..target = 60
      ..isManual = false,
    MissionItem()
      ..title = 'Review Flashcards'
      ..xpReward = 20
      ..type = MissionType.revision
      ..target = 1
      ..isManual = false,
    MissionItem()
      ..title = 'Complete 5 Study Blocks'
      ..xpReward = 100
      ..type = MissionType.studyBlocks
      ..target = 5
      ..isManual = false,
    MissionItem()
      ..title = 'Focus for 2 Hours'
      ..xpReward = 80
      ..type = MissionType.focusTime
      ..target = 120
      ..isManual = false,
    MissionItem()
      ..title = 'Read for 30 minutes'
      ..xpReward = 30
      ..type = MissionType.custom
      ..target = 1
      ..isManual = true,
  ];

  @override
  void initState() {
    super.initState();
    // Deep copy current items or match with available
    _selectedItems = List.from(widget.currentItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Daily Missions'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose up to 4 missions for today.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Gap(16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _availableMissions.length,
                itemBuilder: (context, index) {
                  final mission = _availableMissions[index];
                  final isSelected = _selectedItems.any((m) => m.title == mission.title);
                  
                  return CheckboxListTile(
                    title: Text(mission.title),
                    subtitle: Text('+${mission.xpReward} XP'),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          if (_selectedItems.length < 4) {
                            _selectedItems.add(mission);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Max 4 missions allowed')),
                            );
                          }
                        } else {
                          _selectedItems.removeWhere((m) => m.title == mission.title);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            ref.read(dailyMissionControllerProvider(widget.date).notifier)
               .setMissions(_selectedItems);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
