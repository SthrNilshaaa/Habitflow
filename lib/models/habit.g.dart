// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      iconIndex: fields[2] as int,
      colorIndex: fields[3] as int,
      frequency: fields[4] as String,
      reminderTime: fields[5] as String?,
      isReminderOn: fields[6] as bool? ?? false,
      type: fields[7] as String,
      createdAt: fields[8] as DateTime,
      history: (fields[9] as List?)?.cast<DateTime>() ?? [],
      description: fields[10] as String?,
      targetDays: fields[11] as int? ?? 30,
      isActive: fields[12] as bool? ?? true,
      isFavorite: fields[13] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconIndex)
      ..writeByte(3)
      ..write(obj.colorIndex)
      ..writeByte(4)
      ..write(obj.frequency)
      ..writeByte(5)
      ..write(obj.reminderTime)
      ..writeByte(6)
      ..write(obj.isReminderOn)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.history)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.targetDays)
      ..writeByte(12)
      ..write(obj.isActive)
      ..writeByte(13)
      ..write(obj.isFavorite);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
