import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_list.dart';
import '../models/word_entry.dart';

class DictionaryService {
  static const String boxName = 'dictionaryListsBox';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<WordList>(boxName);
    }
  }

  Box<WordList> get box => Hive.box<WordList>(boxName);

  List<WordList> getAllLists() {
    return box.values.toList();
  }

  List<WordEntry> getAllActiveWords() {
    final activeLists = box.values.where((list) => list.isActive);
    final allWords = <WordEntry>[];
    for (var list in activeLists) {
      allWords.addAll(list.words);
    }
    return allWords;
  }

  Future<void> createList(WordList list) async {
    await box.put(list.id, list);
  }

  Future<void> updateList(WordList list) async {
    await list.save();
  }

  Future<void> deleteList(String id) async {
    await box.delete(id);
  }

  Future<void> addWordToList(String listId, WordEntry word) async {
    final list = box.get(listId);
    if (list != null) {
      list.words.add(word);
      await list.save();
    }
  }

  Future<void> removeWordFromList(String listId, String wordId) async {
    final list = box.get(listId);
    if (list != null) {
      list.words.removeWhere((w) => w.id == wordId);
      await list.save();
    }
  }
}
