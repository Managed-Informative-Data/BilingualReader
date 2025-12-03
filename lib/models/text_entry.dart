import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'text_entry.g.dart';

@HiveType(typeId: 1)
class TextEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  double lastReadPosition; // Scroll position or percentage

  @HiveField(4)
  final DateTime createdAt;

  TextEntry({
    String? id,
    required this.title,
    required this.content,
    this.lastReadPosition = 0.0,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();
}
