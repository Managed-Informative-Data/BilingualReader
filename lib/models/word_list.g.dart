// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordListAdapter extends TypeAdapter<WordList> {
  @override
  final int typeId = 2;

  @override
  WordList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordList(
      id: fields[0] as String?,
      name: fields[1] as String,
      words: (fields[2] as List?)?.cast<WordEntry>(),
      isActive: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, WordList obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.words)
      ..writeByte(3)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
