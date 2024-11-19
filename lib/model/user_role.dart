class UserRole {
  String id;
  String label;

  UserRole({
    required this.id,
    required this.label,
  });

  // Factory constructor to create a UserRole from a map
  factory UserRole.fromMap(Map<String, dynamic> map) {
    return UserRole(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
    );
  }

  // Method to convert UserRole to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
    };
  }
}
