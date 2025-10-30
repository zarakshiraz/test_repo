// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListItemAdapter extends TypeAdapter<ListItem> {
  @override
  final int typeId = 1;

  @override
  ListItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListItem(
      id: fields[0] as String,
      listId: fields[1] as String,
      content: fields[2] as String,
      isCompleted: fields[3] as bool,
      completedByUserId: fields[4] as String?,
      completedAt: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      createdByUserId: fields[8] as String,
      order: fields[9] as int,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ListItem obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.listId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedByUserId)
      ..writeByte(5)
      ..write(obj.completedAt)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.createdByUserId)
      ..writeByte(9)
      ..write(obj.order)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
