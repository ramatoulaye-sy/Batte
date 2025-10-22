import 'package:hive/hive.dart';

@HiveType(typeId: 50)
class OutboxItem {
  @HiveField(0)
  final String id; // local unique id

  @HiveField(1)
  final String type; // e.g., 'waste.create', 'profile.update'

  @HiveField(2)
  final Map<String, dynamic> payload;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int retries;

  OutboxItem({
    required this.id,
    required this.type,
    required this.payload,
    DateTime? createdAt,
    this.retries = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  OutboxItem copyWith({int? retries, Map<String, dynamic>? payload}) {
    return OutboxItem(
      id: id,
      type: type,
      payload: payload ?? this.payload,
      createdAt: createdAt,
      retries: retries ?? this.retries,
    );
  }
}

class OutboxItemAdapter extends TypeAdapter<OutboxItem> {
  @override
  final int typeId = 50;

  @override
  OutboxItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return OutboxItem(
      id: fields[0] as String,
      type: fields[1] as String,
      payload: Map<String, dynamic>.from(fields[2] as Map),
      createdAt: fields[3] as DateTime,
      retries: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OutboxItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.payload)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retries);
  }
}
