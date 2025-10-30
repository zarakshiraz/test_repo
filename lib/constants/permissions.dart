enum PermissionRole {
  viewer,
  editor,
  owner,
}

extension PermissionRoleExtension on PermissionRole {
  String get value {
    switch (this) {
      case PermissionRole.viewer:
        return 'viewer';
      case PermissionRole.editor:
        return 'editor';
      case PermissionRole.owner:
        return 'owner';
    }
  }

  String get displayName {
    switch (this) {
      case PermissionRole.viewer:
        return 'View Only';
      case PermissionRole.editor:
        return 'Can Edit';
      case PermissionRole.owner:
        return 'Owner';
    }
  }

  bool get canEdit => this == PermissionRole.editor || this == PermissionRole.owner;
  bool get canShare => this == PermissionRole.owner;
  bool get canDelete => this == PermissionRole.owner;
}

PermissionRole permissionRoleFromString(String value) {
  switch (value) {
    case 'viewer':
      return PermissionRole.viewer;
    case 'editor':
      return PermissionRole.editor;
    case 'owner':
      return PermissionRole.owner;
    default:
      return PermissionRole.viewer;
  }
}
