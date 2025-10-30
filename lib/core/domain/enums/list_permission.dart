enum ListPermissionType {
  viewOnly,
  editor,
  owner;

  String get displayName {
    switch (this) {
      case ListPermissionType.viewOnly:
        return 'View Only';
      case ListPermissionType.editor:
        return 'Can Edit';
      case ListPermissionType.owner:
        return 'Owner';
    }
  }

  bool get canEdit => this == ListPermissionType.editor || this == ListPermissionType.owner;
  bool get canManagePermissions => this == ListPermissionType.owner;
  bool get isOwner => this == ListPermissionType.owner;
}
