import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_providers.dart';
import '../models/word_entry.dart';
import '../models/word_list.dart';

class DictionaryScreen extends ConsumerWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(dictionaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionary Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to Defaults',
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAiPromptCard(context),
          Expanded(
            child: lists.isEmpty
                ? const Center(child: Text('No lists yet. Create one!'))
                : ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return ListTile(
                        title: Text(list.name),
                        subtitle: Text('${list.words.length} words'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: list.isActive,
                              onChanged: (val) {
                                list.isActive = val;
                                ref
                                    .read(dictionaryProvider.notifier)
                                    .updateList(list);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                ref
                                    .read(dictionaryProvider.notifier)
                                    .deleteList(list.id);
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordListScreen(list: list),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dictionary_list_fab',
        onPressed: () {
          _showAddListOptions(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAiPromptCard(BuildContext context) {
    const String promptText =
        'Generate a JSON word list for a language learning app. '
        'The format must be: {"name": "Topic Name", "words": [{"word": "term", "translation": "meaning", "pronunciation": "sound"}]}. '
        'Create a list of 15 common words related to [TOPIC]. The base language is [LANGUAGE YOU KNOW], and the language to translate to is [LANGUAGE TO TRANSLATE TO].'
        'Exemple: {"name": "Chinese Beginner Pinyin+Character", "words": [{"word": "I","translation": "我","pronunciation": "wǒ"}, ... ]},';

    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Create with AI',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(const ClipboardData(text: promptText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prompt copied to clipboard!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy Prompt'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Use this prompt with ChatGPT, Gemini or other any LLM to generate lists you need:',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                promptText,
                style: TextStyle(fontFamily: 'monospace', fontSize: 11),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Dictionary'),
        content: const Text(
          'This will delete all your current lists and restore the default beginner dictionary. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(dictionaryProvider.notifier).resetToDefault();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAddListOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create Manually'),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateListDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_open),
                title: const Text('Import from JSON File'),
                onTap: () {
                  Navigator.pop(context);
                  _importListFromFile(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.paste),
                title: const Text('Paste JSON Text'),
                onTap: () {
                  Navigator.pop(context);
                  _showPasteJsonDialog(context, ref);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPasteJsonDialog(BuildContext context, WidgetRef ref) {
    final contentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste JSON'),
        content: TextField(
          controller: contentController,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText:
                '[{"word": "hello", "translation": "你好", "pronunciation": "nǐhǎo"}]',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final count = await _createListFromJson(
                  ref,
                  contentController.text,
                  'Pasted List',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Imported list with $count words')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importListFromFile(BuildContext context, WidgetRef ref) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final path = result.files.single.path;
        if (path == null) {
          throw const FileSystemException("File path not available");
        }

        final file = File(path);
        final content = await file.readAsString();

        final name = result.files.single.name.replaceAll('.json', '');

        // Run logic WITHOUT context first
        final count = await _createListFromJson(ref, content, name);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported "$name" with $count words')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Error'),
            content: Text('Failed to import file:\n$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<int> _createListFromJson(
    WidgetRef ref,
    String content,
    String defaultName,
  ) async {
    final dynamic decoded = jsonDecode(content);
    String name = defaultName;
    List<dynamic> wordsJson = [];

    if (decoded is Map<String, dynamic>) {
      name = decoded['name'] ?? defaultName;
      wordsJson = decoded['words'] ?? [];
    } else if (decoded is List) {
      wordsJson = decoded;
    } else {
      throw const FormatException(
        'Invalid JSON format: Root must be Object or List',
      );
    }

    final List<WordEntry> words = wordsJson.map((w) {
      return WordEntry(
        word: w['word'] ?? '',
        translation: w['translation'] ?? '',
        pronunciation: w['pronunciation'] ?? '',
      );
    }).toList();

    final newList = WordList(name: name, words: words);
    await ref.read(dictionaryProvider.notifier).createList(newList);

    return words.length;
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Word List'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'List Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newList = WordList(name: nameController.text.trim());
                ref.read(dictionaryProvider.notifier).createList(newList);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class WordListScreen extends ConsumerWidget {
  final WordList list;

  const WordListScreen({super.key, required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider to get updates, but we need to find *this* list in the list of lists
    // to ensure we have the latest version (e.g. after adding a word).
    // Alternatively, we can just rely on the fact that the list object is mutated in memory
    // and we might need to force rebuild.
    // Better approach: Watch the provider, find the list by ID.
    final allLists = ref.watch(dictionaryProvider);
    final currentList = allLists.firstWhere(
      (l) => l.id == list.id,
      orElse: () => list, // Fallback if deleted
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(currentList.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Edit JSON',
            onPressed: () => _showEditJsonDialog(context, ref, currentList),
          ),
        ],
      ),
      body: currentList.words.isEmpty
          ? const Center(child: Text('No words in this list.'))
          : ListView.builder(
              itemCount: currentList.words.length,
              itemBuilder: (context, index) {
                final word = currentList.words[index];
                return ListTile(
                  title: Text(word.word),
                  subtitle: Text(
                    '${word.translation} (${word.pronunciation})',
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'Microsoft YaHei',
                        'SimSun',
                        'Segoe UI',
                        'Roboto',
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      ref
                          .read(dictionaryProvider.notifier)
                          .removeWordFromList(currentList.id, word.id);
                    },
                  ),
                  onTap: () {
                    _showWordDialog(context, ref, currentList.id, word);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'word_list_fab',
        onPressed: () {
          _showWordDialog(context, ref, currentList.id, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showWordDialog(
    BuildContext context,
    WidgetRef ref,
    String listId,
    WordEntry? existingWord,
  ) {
    final wordController = TextEditingController(
      text: existingWord?.word ?? '',
    );
    final translationController = TextEditingController(
      text: existingWord?.translation ?? '',
    );
    final pronunciationController = TextEditingController(
      text: existingWord?.pronunciation ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingWord == null ? 'Add Word' : 'Edit Word'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: wordController,
                  decoration: const InputDecoration(
                    labelText: 'Word (e.g. book)',
                  ),
                ),
                TextField(
                  controller: translationController,
                  decoration: const InputDecoration(
                    labelText: 'Translation (e.g. 书)',
                  ),
                ),
                TextField(
                  controller: pronunciationController,
                  decoration: const InputDecoration(
                    labelText: 'Pronunciation (e.g. shū)',
                  ),
                  style: const TextStyle(
                    fontFamilyFallback: [
                      'Microsoft YaHei',
                      'SimSun',
                      'Segoe UI',
                      'Roboto',
                    ],
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
            TextButton(
              onPressed: () {
                final word = wordController.text.trim();
                final translation = translationController.text.trim();
                final pronunciation = pronunciationController.text.trim();

                if (word.isNotEmpty && translation.isNotEmpty) {
                  if (existingWord == null) {
                    final newWord = WordEntry(
                      word: word,
                      translation: translation,
                      pronunciation: pronunciation,
                    );
                    ref
                        .read(dictionaryProvider.notifier)
                        .addWordToList(listId, newWord);
                  } else {
                    final updatedWord = existingWord.copyWith(
                      word: word,
                      translation: translation,
                      pronunciation: pronunciation,
                    );

                    final lists = ref.read(dictionaryProvider);
                    final list = lists.firstWhere((l) => l.id == listId);
                    final index = list.words.indexWhere(
                      (w) => w.id == existingWord.id,
                    );
                    if (index != -1) {
                      list.words[index] = updatedWord;
                      ref.read(dictionaryProvider.notifier).updateList(list);
                    }
                  }
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

  void _showEditJsonDialog(BuildContext context, WidgetRef ref, WordList list) {
    final jsonMap = {
      'name': list.name,
      'words': list.words
          .map(
            (w) => {
              'word': w.word,
              'translation': w.translation,
              'pronunciation': w.pronunciation,
            },
          )
          .toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);
    final contentController = TextEditingController(text: jsonString);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit List JSON'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: contentController,
            maxLines: 20,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              try {
                final dynamic decoded = jsonDecode(contentController.text);
                if (decoded is! Map<String, dynamic>) {
                  throw const FormatException('Root must be a JSON object');
                }

                final String newName = decoded['name'] ?? list.name;
                final List<dynamic> wordsJson = decoded['words'] ?? [];

                final List<WordEntry> newWords = wordsJson.map((w) {
                  return WordEntry(
                    word: w['word'] ?? '',
                    translation: w['translation'] ?? '',
                    pronunciation: w['pronunciation'] ?? '',
                  );
                }).toList();

                // Update the list
                list.name = newName;
                list.words = newWords;
                ref.read(dictionaryProvider.notifier).updateList(list);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('List updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error parsing JSON: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
