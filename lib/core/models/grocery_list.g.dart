// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grocery_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListPermissionAdapter extends TypeAdapter<ListPermission> {
  @override
  final int typeId = 2;

  @override
  ListPermission read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ListPermission.viewOnly;
      case 1:
        return ListPermission.canEdit;
      default:
        return ListPermission.viewOnly;
    }
  }

  @override
  void write(BinaryWriter writer, ListPermission obj) {
    switch (obj) {
      case ListPermission.viewOnly:
        writer.writeByte(0);
        break;
      case ListPermission.canEdit:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListPermissionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ListStatusAdapter extends TypeAdapter<ListStatus> {
  @override
  final int typeId = 3;

  @override
  ListStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ListStatus.active;
      case 1:
        return ListStatus.completed;
      case 2:
        return ListStatus.archived;
      default:
        return ListStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, ListStatus obj) {
    switch (obj) {
      case ListStatus.active:
        writer.writeByte(0);
        break;
      case ListStatus.completed:
        writer.writeByte(1);
        break;
      case ListStatus.archived:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SharedUserAdapter extends TypeAdapter<SharedUser> {
  @override
  final int typeId = 4;

  @override
  SharedUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedUser(
      userId: fields[0] as String,
      permission: fields[1] as ListPermission,
      sharedAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SharedUser obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.permission)
      ..writeByte(2)
      ..write(obj.sharedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GroceryListAdapter extends TypeAdapter<GroceryList> {
  @override
  final int typeId = 5;

  @override
  GroceryList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroceryList(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      createdByUserId: fields[3] as String,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      sharedWith: (fields[6] as List?)?.cast<SharedUser>() ?? const [],
      status: fields[7] as ListStatus? ?? ListStatus.active,
      completedAt: fields[8] as DateTime?,
      isSaved: fields[9] as bool? ?? false,
      reminderTime: fields[10] as String?,
      remindEveryone: fields[11] as bool? ?? false,
      category: fields[12] as String?,
      totalItems: fields[13] as int? ?? 0,
      completedItems: fields[14] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, GroceryList obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdByUserId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.sharedWith)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.completedAt)
      ..writeByte(9)
      ..write(obj.isSaved)
      ..writeByte(10)
      ..write(obj.reminderTime)
      ..writeByte(11)
      ..write(obj.remindEveryone)
      ..writeByte(12)
      ..write(obj.category)
      ..writeByte(13)
      ..write(obj.totalItems)
      ..writeByte(14)
      ..write(obj.completedItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}