// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feeding_record.dart';

class FeedingRecordAdapter extends TypeAdapter<FeedingRecord> {
  @override
  final int typeId = 0;

  @override
  FeedingRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FeedingRecord(
      id: fields[0] as String,
      type: fields[1] as String,
      side: fields[2] as String?,
      durationSeconds: fields[3] as int,
      amountMl: fields[4] as int?,
      startedAt: fields[5] as DateTime,
      endedAt: fields[6] as DateTime,
      spitUpAmount: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FeedingRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.side)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.amountMl)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.endedAt)
      ..writeByte(7)
      ..write(obj.spitUpAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedingRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
