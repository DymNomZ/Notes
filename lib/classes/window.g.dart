// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'window.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WindowAdapter extends TypeAdapter<Window> {
  @override
  final int typeId = 1;

  @override
  Window read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Window(
      barColor: fields[0] as Color,
      bodyColor: fields[1] as Color,
    );
  }

  @override
  void write(BinaryWriter writer, Window obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.barColor)
      ..writeByte(1)
      ..write(obj.bodyColor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
