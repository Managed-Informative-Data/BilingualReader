import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dictionary_service.dart';
import '../services/library_service.dart';
import '../services/substitution_service.dart';
import '../models/word_entry.dart';
import '../models/text_entry.dart';
import '../models/word_list.dart';
import '../utils/default_data.dart';

// Services
final dictionaryServiceProvider = Provider<DictionaryService>((ref) {
  return DictionaryService();
});

final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService();
});

final substitutionServiceProvider = Provider<SubstitutionService>((ref) {
  return SubstitutionService();
});

// Initialization Provider
final appInitializationProvider = FutureProvider<void>((ref) async {
  final dictionaryService = ref.read(dictionaryServiceProvider);
  final libraryService = ref.read(libraryServiceProvider);

  await dictionaryService.init();
  await libraryService.init();

  // Populate defaults if missing
  // We check by ID to ensure they exist even if user added other things

  // Check Dictionary List
  final existingLists = dictionaryService.getAllLists();
  final hasDefaultList = existingLists.any(
    (l) => l.id == DefaultData.defaultListId,
  );

  if (!hasDefaultList) {
    await dictionaryService.createList(DefaultData.beginnerChineseList);
  }

  // Check Library Text
  final existingTexts = libraryService.getAllTexts();
  final hasDefaultStory = existingTexts.any(
    (t) => t.id == DefaultData.defaultStoryId,
  );

  if (!hasDefaultStory) {
    await libraryService.addText(DefaultData.defaultStory);
  }
}); // Data Providers (Notifiers)

// Dictionary List
class DictionaryNotifier extends Notifier<List<WordList>> {
  late DictionaryService _service;

  @override
  List<WordList> build() {
    _service = ref.read(dictionaryServiceProvider);
    try {
      return _service.getAllLists();
    } catch (e) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = _service.getAllLists();
  }

  Future<void> createList(WordList list) async {
    await _service.createList(list);
    await refresh();
  }

  Future<void> updateList(WordList list) async {
    await _service.updateList(list);
    await refresh();
  }

  Future<void> deleteList(String id) async {
    await _service.deleteList(id);
    await refresh();
  }

  Future<void> addWordToList(String listId, WordEntry word) async {
    await _service.addWordToList(listId, word);
    await refresh();
  }

  Future<void> removeWordFromList(String listId, String wordId) async {
    await _service.removeWordFromList(listId, wordId);
    await refresh();
  }

  Future<void> resetToDefault() async {
    final lists = _service.getAllLists();
    for (var list in lists) {
      await _service.deleteList(list.id);
    }
    await _service.createList(DefaultData.beginnerChineseList);
    await refresh();
  }
}

final dictionaryProvider = NotifierProvider<DictionaryNotifier, List<WordList>>(
  DictionaryNotifier.new,
);

// Active Words Provider (for substitution)
final activeWordsProvider = Provider<List<WordEntry>>((ref) {
  final lists = ref.watch(dictionaryProvider);
  final activeLists = lists.where((l) => l.isActive);
  final allWords = <WordEntry>[];
  for (var list in activeLists) {
    allWords.addAll(list.words);
  }
  return allWords;
});

// Library List
class LibraryNotifier extends Notifier<List<TextEntry>> {
  late LibraryService _service;

  @override
  List<TextEntry> build() {
    _service = ref.read(libraryServiceProvider);
    try {
      return _service.getAllTexts();
    } catch (e) {
      return [];
    }
  }

  Future<void> refresh() async {
    state = _service.getAllTexts();
  }

  Future<void> addText(TextEntry text) async {
    await _service.addText(text);
    await refresh();
  }

  Future<void> deleteText(String id) async {
    await _service.deleteText(id);
    await refresh();
  }

  Future<void> updateProgress(String id, double position) async {
    await _service.updateProgress(id, position);
    // No need to refresh full list for progress unless we show it in the list
    // But let's keep it simple.
    await refresh();
  }
}

final libraryProvider = NotifierProvider<LibraryNotifier, List<TextEntry>>(
  LibraryNotifier.new,
);
