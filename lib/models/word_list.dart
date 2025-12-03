import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'word_entry.dart';

part 'word_list.g.dart';

@HiveType(typeId: 2)
class WordList extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<WordEntry> words;

  @HiveField(3)
  bool isActive;

  WordList({
    String? id,
    required this.name,
    List<WordEntry>? words,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4(),
       words = words ?? [];
}
