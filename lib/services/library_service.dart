import 'package:hive_flutter/hive_flutter.dart';
import '../models/text_entry.dart';

class LibraryService {
  static const String boxName = 'libraryBox';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<TextEntry>(boxName);
    }
  }

  Box<TextEntry> get box => Hive.box<TextEntry>(boxName);

  List<TextEntry> getAllTexts() {
    // Sort by creation date descending by default
    final list = box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> addText(TextEntry text) async {
    await box.put(text.id, text);
  }

  Future<void> updateText(TextEntry text) async {
    await box.put(text.id, text);
  }

  Future<void> deleteText(String id) async {
    await box.delete(id);
  }

  Future<void> updateProgress(String id, double position) async {
    final text = box.get(id);
    if (text != null) {
      text.lastReadPosition = position;
      await text.save();
    }
  }
}
