// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      phone: fields[1] as String,
      name: fields[2] as String?,
      email: fields[3] as String?,
      role: fields[4] as String,
      balance: fields[5] as double,
      language: fields[6] as String,
      voiceEnabled: fields[7] as bool,
      totalWeight: fields[8] as double,
      ecoScore: fields[9] as int,
      profilePicture: fields[10] as String?,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.role)
      ..writeByte(5)
      ..write(obj.balance)
      ..writeByte(6)
      ..write(obj.language)
      ..writeByte(7)
      ..write(obj.voiceEnabled)
      ..writeByte(8)
      ..write(obj.totalWeight)
      ..writeByte(9)
      ..write(obj.ecoScore)
      ..writeByte(10)
      ..write(obj.profilePicture)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
