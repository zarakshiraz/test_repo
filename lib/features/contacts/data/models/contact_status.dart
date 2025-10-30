enum ContactStatus {
  pending,
  accepted,
  blocked;

  String toJson() => name;

  static ContactStatus fromJson(String json) {
    return ContactStatus.values.firstWhere(
      (status) => status.name == json,
      orElse: () => ContactStatus.pending,
    );
  }
}
