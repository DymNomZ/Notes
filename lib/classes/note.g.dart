// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      title: fields[0] as String,
      content: fields[1] as String,
      modifiedTime: fields[2] as DateTime,
      barColor: fields[3] as Color,
      bodyColor: fields[4] as Color,
      creationTime: fields[5] as DateTime,
      folder: fields[6] == null ? 'Notes' : fields[6] as String,
      orderIndex: fields[7] == null ? -1 : fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.modifiedTime)
      ..writeByte(3)
      ..write(obj.barColor)
      ..writeByte(4)
      ..write(obj.bodyColor)
      ..writeByte(5)
      ..write(obj.creationTime)
      ..writeByte(6)
      ..write(obj.folder)
      ..writeByte(7)
      ..write(obj.orderIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
