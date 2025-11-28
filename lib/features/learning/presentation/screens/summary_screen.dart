import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../providers/summary_provider.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  final _textController = TextEditingController();
  String _generatedSummary = '';
  bool _isGenerating = false;
  
  String _selectedTone = 'Standard';
  String _selectedLength = 'Medium';
  String _selectedFormat = 'Paragraph';

  final _tones = ['Standard', 'Academic', 'Simple', 'Professional'];
  final _lengths = ['Short', 'Medium', 'Long'];
  final _formats = ['Paragraph', 'Bullet Points', 'Key Concepts'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_textController.text.isEmpty) return;

    setState(() {
      _generatedSummary = '';
      _isGenerating = true;
    });

    ref.read(summaryNotifierProvider.notifier).generateSummary(
      _textController.text,
      tone: _selectedTone,
      length: _selectedLength,
      format: _selectedFormat,
    );
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      
      if (pickedFile == null) return;

      setState(() => _isGenerating = true);

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      if (recognizedText.text.isNotEmpty) {
        if (mounted) {
          setState(() {
            _textController.text = recognizedText.text;
            _isGenerating = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Text scanned successfully!')),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No text found in image.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
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

  @override
  Widget build(BuildContext context) {
    // Listen to the stream manually to accumulate text
    ref.listen(summaryNotifierProvider, (previous, next) {
      next.whenData((chunk) {
        setState(() {
          _generatedSummary += chunk;
        });
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Options Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildDropdown('Tone', _selectedTone, _tones, (v) => setState(() => _selectedTone = v!)),
                  const Gap(12),
                  _buildDropdown('Length', _selectedLength, _lengths, (v) => setState(() => _selectedLength = v!)),
                  const Gap(12),
                  _buildDropdown('Format', _selectedFormat, _formats, (v) => setState(() => _selectedFormat = v!)),
                ],
              ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Paste text below to summarize:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _isGenerating ? null : _showScanOptions,
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('Scan Text'),
                ),
              ],
            ),
            const Gap(8),
            TextField(
              controller: _textController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Paste long text here or scan from image...',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: _isGenerating && _generatedSummary.isEmpty ? null : _generate, // Allow regenerating
              icon: _isGenerating && _generatedSummary.isEmpty
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.summarize),
              label: Text(_isGenerating && _generatedSummary.isEmpty ? 'Generating...' : 'Summarize'),
            ),
            const Gap(24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                if (_generatedSummary.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      // Copy to clipboard logic would go here
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                    },
                  ),
              ],
            ),
            const Gap(8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _generatedSummary.isEmpty 
                        ? 'Summary will appear here.' 
                        : _generatedSummary,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium,
          icon: const Icon(Icons.arrow_drop_down),
          isDense: true,
        ),
      ),
    );
  }
}
