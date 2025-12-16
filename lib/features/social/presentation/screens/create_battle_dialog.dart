import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/battle_repository.dart';
import '../../data/datasources/default_content_service.dart';
import '../../../settings/presentation/providers/user_provider.dart';

class CreateBattleDialog extends ConsumerStatefulWidget {
  const CreateBattleDialog({super.key});

  @override
  ConsumerState<CreateBattleDialog> createState() => _CreateBattleDialogState();
}

class _CreateBattleDialogState extends ConsumerState<CreateBattleDialog> {
  final topicController = TextEditingController();
  final countController = TextEditingController(text: '5');
  final timeController = TextEditingController(text: '30');
  String language = 'English';
  
  bool useOffline = false;
  bool isDataReady = false;
  bool isCheckingData = false;
  bool isDownloading = false;
  double downloadProgress = 0.0;

  @override
  void dispose() {
    topicController.dispose();
    countController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Future<void> checkDataAvailability() async {
    if (!mounted) return;
    setState(() => isCheckingData = true);
    
    final available = await ref.read(defaultContentServiceProvider).isDataAvailable();
    
    if (mounted) {
      setState(() {
        isDataReady = available;
        isCheckingData = false;
      });
    }
  }

  Future<void> _startDownload() async {
    try {
      if (!mounted) return;
      setState(() {
        isDownloading = true;
        downloadProgress = 0.0;
      });
      print('CreateBattleDialog: Starting download...');
      
      await ref.read(defaultContentServiceProvider).downloadData(
        onProgress: (p) {
          print('CreateBattleDialog: Download Progress: $p');
          if (mounted) {
            setState(() => downloadProgress = p);
          }
        },
      );
      print('CreateBattleDialog: Download finished.');
      
      if (mounted) {
        setState(() => isDownloading = false);
        await checkDataAvailability();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download Complete!')));
      }
    } catch (e, stack) {
      print('CreateBattleDialog: Download Error: $e\n$stack');
      if (mounted) {
        setState(() => isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Download Failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Battle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: 'Topic (e.g. Math, History)'),
            ),
             if (useOffline)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('Offline mode supports: Math, Science, History, or "General"', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ),
            const Gap(16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: countController,
                    decoration: const InputDecoration(labelText: 'Questions'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: 'Sec/Q'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const Gap(16),
            DropdownButtonFormField<String>(
              value: language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: ['English', 'Spanish', 'French', 'German', 'Bengali'].map((l) {
                return DropdownMenuItem(value: l, child: Text(l));
              }).toList(),
              onChanged: (v) => setState(() => language = v!),
            ),
            
            const Gap(24),
            const Divider(),
            SwitchListTile(
              title: const Text('Use Offline Data'),
              subtitle: const Text('No AI. Uses downloadable question pack.'),
              value: useOffline,
              onChanged: (val) {
                setState(() => useOffline = val);
                if (val) {
                  checkDataAvailability();
                }
              },
            ),
            
            if (useOffline) ...[
               if (isCheckingData)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child:  LinearProgressIndicator(),
                  ),
               
               if (!isDataReady)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      children: [
                        const Text('Offline data not found.', style: TextStyle(color: Colors.orange)),
                        if (isDownloading)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                  LinearProgressIndicator(
                                    value: downloadProgress, 
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                  const Gap(8),
                                  Text(
                                    '${(downloadProgress * 100).toInt()}% Downloading...',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                        else
                          TextButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Download Default Pack (Offline)'),
                            onPressed: _startDownload,
                          )
                      ],
                    ),
                  )
               else
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text('Offline Data Ready', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        if (isDownloading)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                  LinearProgressIndicator(
                                    value: downloadProgress, 
                                    minHeight: 10,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                  const Gap(8),
                                  Text(
                                    '${(downloadProgress * 100).toInt()}% Updating...',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                        else
                          TextButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Update Data Pack', style: TextStyle(fontSize: 12)),
                            onPressed: _startDownload,
                          )
                      ],
                    ),
                  ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (topicController.text.isEmpty && !useOffline) return;
            if (useOffline && !isDataReady) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please download the offline data first.')));
               return;
            }
            
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) return;
            
            String name = ref.read(userNotifierProvider).value?.name ?? '';
            if (name.isEmpty) {
              final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
              name = userDoc.data()?['name'] ?? 'Unknown Host';
            }

            try {
              final battleId = await ref.read(battleRepositoryProvider).createBattle(
                creatorId: user.uid,
                creatorName: name,
                topic: topicController.text.isEmpty ? 'General' : topicController.text,
                language: language,
                questionCount: int.tryParse(countController.text) ?? 5,
                timePerQuestion: int.tryParse(timeController.text) ?? 30,
                useDefaultData: useOffline,
              );
              
              if (context.mounted) {
                Navigator.pop(context);
                context.push('/social/battle/$battleId/lobby');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
