import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'word_entry.g.dart';

@HiveType(typeId: 0)
class WordEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String word; // The word to replace (e.g., "book")

  @HiveField(2)
  final String translation; // The replacement (e.g., "书")

  @HiveField(3)
  final String pronunciation; // The pronunciation (e.g., "shū")

  WordEntry({
    String? id,
    required this.word,
    required this.translation,
    required this.pronunciation,
  }) : id = id ?? const Uuid().v4();

  WordEntry copyWith({
    String? word,
    String? translation,
    String? pronunciation,
  }) {
    return WordEntry(
      id: id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      pronunciation: pronunciation ?? this.pronunciation,
    );
  }
}
