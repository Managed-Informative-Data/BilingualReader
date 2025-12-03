// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordEntryAdapter extends TypeAdapter<WordEntry> {
  @override
  final int typeId = 0;

  @override
  WordEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordEntry(
      id: fields[0] as String?,
      word: fields[1] as String,
      translation: fields[2] as String,
      pronunciation: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WordEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.translation)
      ..writeByte(3)
      ..write(obj.pronunciation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
