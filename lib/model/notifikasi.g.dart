// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifikasi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotifikasiAdapter extends TypeAdapter<Notifikasi> {
  @override
  final int typeId = 1;

  @override
  Notifikasi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notifikasi(
      sholat: fields[0] as String,
      notifTimes: fields[1] as String,
      userId: fields[2] as String,
      id: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Notifikasi obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.sholat)
      ..writeByte(1)
      ..write(obj.notifTimes)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotifikasiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
