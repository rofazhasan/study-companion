import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';
import 'package:study_companion/features/learning/data/models/note.dart';
import 'package:study_companion/features/learning/presentation/providers/notes_provider.dart';
import 'package:study_companion/features/ai_chat/presentation/providers/chat_provider.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final Note? note;

  const NoteDetailScreen({super.key, this.note});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<String> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _images = widget.note?.images?.toList() ?? [];
    _isEditing = widget.note != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((e) => e.path));
      });
    }
  }

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _images.add(photo.path);
      });
    }
  }

  void _saveNote() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty && _images.isEmpty) {
      return;
    }

    if (_isEditing && widget.note != null) {
      ref.read(notesNotifierProvider.notifier).updateNote(
            widget.note!.id,
            _titleController.text,
            _contentController.text,
            _images,
          );
    } else {
      ref.read(notesNotifierProvider.notifier).addNote(
            _titleController.text,
            _contentController.text,
            images: _images,
          );
    }
    Navigator.pop(context);
  }

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note?'),
        content: const Text('Are you sure you want to delete this note? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(notesNotifierProvider.notifier).deleteNote(widget.note!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _saveNote,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_outlined),
            onPressed: _showScanOptions,
            tooltip: 'Scan Text',
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: _takePicture,
            tooltip: 'Take Picture',
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: _pickImages,
            tooltip: 'Add Images',
          ),
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () => _showAIMagicDialog(context, ref),
            tooltip: 'AI Magic',
          ),
          if (widget.note != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteNote();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        Gap(8),
                        Text('Delete Note', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              },
            ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          if (_images.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_images[index]),
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _images.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const Gap(8),
                  if (widget.note != null)
                    Text(
                      DateFormat.yMMMd().add_jm().format(widget.note!.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  const Gap(16),
                  TextField(
                    controller: _contentController,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                    decoration: const InputDecoration(
                      hintText: 'Start writing...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      if (pickedFile == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        if (recognizedText.text.isNotEmpty) {
          setState(() {
            if (_contentController.text.isNotEmpty) {
              _contentController.text += '\n\n${recognizedText.text}';
            } else {
              _contentController.text = recognizedText.text;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Text scanned and appended!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No text found in image.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning text: $e')),
        );
      }
    }
  }

  void _showScanOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndScanImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndScanImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAIMagicDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.summarize_outlined),
            title: const Text('Summarize'),
            onTap: () {
              Navigator.pop(context);
              _performAIOperation(ref, 'Summarize this note:\n\n${_contentController.text}');
            },
          ),
          ListTile(
            leading: const Icon(Icons.spellcheck),
            title: const Text('Fix Grammar & Spelling'),
            onTap: () {
              Navigator.pop(context);
              _performAIOperation(ref, 'Fix grammar and spelling in this note, keep the same tone:\n\n${_contentController.text}', replace: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: const Text('Continue Writing'),
            onTap: () {
              Navigator.pop(context);
              _performAIOperation(ref, 'Continue writing this note:\n\n${_contentController.text}', append: true);
            },
          ),
          const Gap(16),
        ],
      ),
    );
  }

  Future<void> _performAIOperation(WidgetRef ref, String prompt, {bool replace = false, bool append = false}) async {
    // Import this at the top: import 'package:study_companion/features/ai_chat/presentation/providers/chat_provider.dart';
    final aiService = ref.read(aiServiceProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final stream = aiService.generateResponse(prompt);
      String result = '';
      await for (final chunk in stream) {
        result += chunk;
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        if (replace) {
          _contentController.text = result;
        } else if (append) {
          _contentController.text += '\n\n$result';
        } else {
          // Show result in a dialog for copying/inserting
          _showResultDialog(result);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Error: $e')),
        );
      }
    }
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Result'),
        content: SingleChildScrollView(child: Text(result)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              _contentController.text += '\n\n$result';
              Navigator.pop(context);
            },
            child: const Text('Append to Note'),
          ),
        ],
      ),
    );
  }
}
