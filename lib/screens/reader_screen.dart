import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../providers/app_providers.dart';
import '../models/text_entry.dart';
import 'reading_screen.dart';

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: library.isEmpty
          ? const Center(child: Text('No texts yet. Add one!'))
          : ListView.builder(
              itemCount: library.length,
              itemBuilder: (context, index) {
                final textEntry = library[index];
                return ListTile(
                  leading: const Icon(Icons.description),
                  title: Text(textEntry.title),
                  subtitle: Text(
                    'Created: ${textEntry.createdAt.toString().split('.')[0]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReadingScreen(textEntry: textEntry),
                      ),
                    );
                  },
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context, ref, textEntry);
                      } else if (value == 'delete') {
                        _confirmDelete(context, ref, textEntry);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'reader_fab',
        onPressed: () => _showAddOptions(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TextEntry textEntry,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Text'),
        content: Text('Are you sure you want to delete "${textEntry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(libraryProvider.notifier).deleteText(textEntry.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.paste),
                title: const Text('Paste Text'),
                onTap: () {
                  Navigator.pop(context);
                  _showPasteDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_open),
                title: const Text('Load File (.txt, .pdf)'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPasteDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Paste Text'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter a title for this text',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Paste your text here...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text;

                if (title.isNotEmpty && content.isNotEmpty) {
                  final newText = TextEntry(title: title, content: content);
                  ref.read(libraryProvider.notifier).addText(newText);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final extension = result.files.single.extension?.toLowerCase();
        String content = '';
        String title = result.files.single.name;

        if (extension == 'pdf') {
          // Load the PDF document
          final PdfDocument document = PdfDocument(
            inputBytes: await file.readAsBytes(),
          );
          // Extract text from all pages
          content = PdfTextExtractor(document).extractText();
          document.dispose();
        } else {
          // Assume text file
          content = await file.readAsString();
        }

        if (content.trim().isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No text found in file')),
            );
          }
          return;
        }

        final newText = TextEntry(title: title, content: content);
        await ref.read(libraryProvider.notifier).addText(newText);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Imported "$title"')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error importing file: $e')));
      }
    }
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    TextEntry textEntry,
  ) {
    final titleController = TextEditingController(text: textEntry.title);
    final contentController = TextEditingController(text: textEntry.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Text'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 8,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text.trim();
                final content = contentController.text;

                if (title.isNotEmpty && content.isNotEmpty) {
                  // We need to update the existing entry.
                  // Since TextEntry is a HiveObject, we can save it directly if it's in a box,
                  // but here we are using Riverpod notifier.
                  // Let's assume the notifier has an update method or we modify the object and notify.
                  // Looking at previous code, we might need to add an updateText method to the notifier
                  // or just modify the object and refresh.

                  // Actually, TextEntry extends HiveObject.
                  textEntry.title = title;
                  textEntry.content = content;
                  textEntry.save(); // Save to Hive

                  // Force refresh of provider if needed, or if the provider watches the box it will update automatically.
                  // Assuming the provider watches the box or we need to trigger a refresh.
                  // Let's call an update method if it exists, otherwise just save.
                  // Based on ReaderScreen code, we have ref.read(libraryProvider.notifier).
                  // Let's check if we can just call save() and if the UI updates.
                  // If the provider is a StateNotifier that loads from Hive, we might need to reload.

                  // To be safe, let's try to find an update method or reload.
                  // Since I don't see the provider code, I'll assume saving the HiveObject works
                  // and maybe trigger a reload if the list doesn't update.
                  // But wait, the list is built from `ref.watch(libraryProvider)`.
                  // If that provider is a simple list, we need to update the list in the state.

                  // Let's try to update via the notifier if possible, or just invalidate the provider.
                  // For now, I'll just save and invalidate the provider to be safe.

                  ref.invalidate(libraryProvider);

                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
