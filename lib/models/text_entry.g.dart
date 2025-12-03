// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TextEntryAdapter extends TypeAdapter<TextEntry> {
  @override
  final int typeId = 1;

  @override
  TextEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextEntry(
      id: fields[0] as String?,
      title: fields[1] as String,
      content: fields[2] as String,
      lastReadPosition: fields[3] as double,
      createdAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TextEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.lastReadPosition)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
