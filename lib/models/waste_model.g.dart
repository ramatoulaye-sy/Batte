// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waste_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WasteModelAdapter extends TypeAdapter<WasteModel> {
  @override
  final int typeId = 1;

  @override
  WasteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WasteModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as String,
      weight: fields[3] as double,
      value: fields[4] as double,
      date: fields[5] as DateTime?,
      binDeviceId: fields[6] as String?,
      synced: fields[7] as bool,
      notes: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WasteModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.value)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.binDeviceId)
      ..writeByte(7)
      ..write(obj.synced)
      ..writeByte(8)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WasteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
