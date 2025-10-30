enum ActivityType {
  listCreated,
  listUpdated,
  listCompleted,
  listArchived,
  itemAdded,
  itemUpdated,
  itemCompleted,
  itemDeleted,
  userAdded,
  userRemoved,
  permissionChanged;

  String get displayName {
    switch (this) {
      case ActivityType.listCreated:
        return 'List Created';
      case ActivityType.listUpdated:
        return 'List Updated';
      case ActivityType.listCompleted:
        return 'List Completed';
      case ActivityType.listArchived:
        return 'List Archived';
      case ActivityType.itemAdded:
        return 'Item Added';
      case ActivityType.itemUpdated:
        return 'Item Updated';
      case ActivityType.itemCompleted:
        return 'Item Completed';
      case ActivityType.itemDeleted:
        return 'Item Deleted';
      case ActivityType.userAdded:
        return 'User Added';
      case ActivityType.userRemoved:
        return 'User Removed';
      case ActivityType.permissionChanged:
        return 'Permission Changed';
    }
  }

  bool get isListActivity => [
        ActivityType.listCreated,
        ActivityType.listUpdated,
        ActivityType.listCompleted,
        ActivityType.listArchived,
      ].contains(this);

  bool get isItemActivity => [
        ActivityType.itemAdded,
        ActivityType.itemUpdated,
        ActivityType.itemCompleted,
        ActivityType.itemDeleted,
      ].contains(this);

  bool get isUserActivity => [
        ActivityType.userAdded,
        ActivityType.userRemoved,
        ActivityType.permissionChanged,
      ].contains(this);
}
